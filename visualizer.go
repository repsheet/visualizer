package main

import (
        "log"
        "fmt"
        "net/http"
        "os"
        "flag"
        "html/template"
        "github.com/gorilla/mux"
        "github.com/gorilla/handlers"
)

type Page struct {
        Active     string
        Summary    Summary
        Actor      Actor
        Pagination map[string]string
}

func NotFoundHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")
        templates, _ := template.ParseFiles(configuration.TemplateFor("layout"), configuration.TemplateFor("404"))
        templates.ExecuteTemplate(response, "layout", Page{})

        return 404, nil
}

func ErrorHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")
        response.WriteHeader(500)
        templates, _ := template.ParseFiles(configuration.TemplateFor("layout"), configuration.TemplateFor("500"))
        templates.ExecuteTemplate(response, "layout", Page{})

        return 500, nil
}

func HeartbeatHandler(response http.ResponseWriter, request *http.Request) {
        response.Header().Set("Content-type", "text/html")
        fmt.Fprintf(response, "OK")
}

func main() {
        logFilePtr   := flag.String("logfile", "logs/visualizer.log", "Path to log file")
        redisHostPtr := flag.String("redisHost", "localhost", "Redis hostname")
        redisPortPtr := flag.Int("redisPort", 6379, "Redis port")
        portPtr      := flag.Int("port", 8080, "Visualizer http port")
        geoIpPtr     := flag.String("geoIpDb", "db/GeoLiteCity.dat", "Path to GeoIP database")
        assetsPtr    := flag.String("assets", ".", "Path to directory containing templates and public folders")
        flag.Parse()

        configuration := &Configuration{
                LogFile: *logFilePtr,
                Port: *portPtr,
                Redis: Redis{Host: *redisHostPtr, Port: *redisPortPtr},
                GeoIPDatabase: *geoIpPtr,
                AssetsDir: *assetsPtr,
        }

        logFile, err := os.OpenFile(configuration.LogFile, os.O_WRONLY | os.O_CREATE | os.O_APPEND, 0666)
        if err != nil {
                fmt.Println("Error accessing log file:", err)
                os.Exit(1)
        }

        r := mux.NewRouter()
        r.NotFoundHandler = configurationHandler{configuration, NotFoundHandler}
        r.Handle("/",            handlers.LoggingHandler(logFile, configurationHandler{configuration, DashboardHandler}))
        r.Handle("/blacklist",   handlers.LoggingHandler(logFile, configurationHandler{configuration, BlacklistHandler}))
        r.Handle("/whitelist",   handlers.LoggingHandler(logFile, configurationHandler{configuration, WhitelistHandler}))
        r.Handle("/marklist",    handlers.LoggingHandler(logFile, configurationHandler{configuration, MarklistHandler}))
        r.Handle("/actors/{id}", handlers.LoggingHandler(logFile, configurationHandler{configuration, ActorHandler}))
        r.Handle("/search",      handlers.LoggingHandler(logFile, configurationHandler{configuration, SearchHandler}))
        r.Handle("/error",       handlers.LoggingHandler(logFile, configurationHandler{configuration, ErrorHandler}))
        r.Handle("/heartbeat",   handlers.LoggingHandler(logFile, http.HandlerFunc(HeartbeatHandler)))
        assets := fmt.Sprintf("%s/public", configuration.AssetsDir)
        r.PathPrefix("/public/").Handler(http.StripPrefix("/public/", http.FileServer(http.Dir(assets))))
        http.Handle("/", r)

        serverString := fmt.Sprintf(":%d", configuration.Port)
        err = http.ListenAndServe(serverString, r)
        if err != nil {
                log.Fatal("Error starting server: ", err)
        }
}
