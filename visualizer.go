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
	Active  string
        Summary Summary
	Actor   Actor
}

func NotFoundHandler(response http.ResponseWriter, request *http.Request) {
        response.Header().Set("Content-type", "text/html")
        templates, _ := template.ParseFiles("templates/layout.html", "templates/404.html")
        templates.ExecuteTemplate(response, "layout", Page{})
}

func ErrorHandler(response http.ResponseWriter, request *http.Request) {
        response.Header().Set("Content-type", "text/html")
	response.WriteHeader(500)
        templates, _ := template.ParseFiles("templates/layout.html", "templates/500.html")
        templates.ExecuteTemplate(response, "layout", Page{})
}

func main() {
	logFilePtr   := flag.String("logfile", "logs/visualizer.log", "Path to log file")
	redisHostPtr := flag.String("redisHost", "localhost", "Redis hostname")
	redisPortPtr := flag.Int("redisPort", 6379, "Redis port")
 	portPtr      := flag.Int("port", 8080, "Visualizer http port")
	flag.Parse()

	connection := connect(*redisHostPtr, *redisPortPtr)

	configuration := &Configuration{
		LogFile: *logFilePtr,
		Port: *portPtr,
		Redis: Redis{Host: *redisHostPtr, Port: *redisPortPtr, Connection: connection},
	}

	logFile, err := os.OpenFile(configuration.LogFile, os.O_WRONLY | os.O_CREATE | os.O_APPEND, 0666)
        if err != nil {
                fmt.Println("Error accessing log file:", err)
                os.Exit(1)
        }

        r := mux.NewRouter()
	r.NotFoundHandler = http.HandlerFunc(NotFoundHandler)
        r.Handle("/",            handlers.LoggingHandler(logFile, configurationHandler{configuration, DashboardHandler}))
	r.Handle("/blacklist",   handlers.LoggingHandler(logFile, configurationHandler{configuration, BlacklistHandler}))
	r.Handle("/whitelist",   handlers.LoggingHandler(logFile, configurationHandler{configuration, WhitelistHandler}))
	r.Handle("/marklist",    handlers.LoggingHandler(logFile, configurationHandler{configuration, MarklistHandler}))
	r.Handle("/actors/{id}", handlers.LoggingHandler(logFile, configurationHandler{configuration, ActorHandler}))
	r.Handle("/error",       handlers.LoggingHandler(logFile, http.HandlerFunc(ErrorHandler)))
        r.PathPrefix("/public/").Handler(http.StripPrefix("/public/", http.FileServer(http.Dir("public"))))
        http.Handle("/", r)

	serverString := fmt.Sprintf("localhost:%d", configuration.Port)
        err = http.ListenAndServe(serverString, r)
        if err != nil {
                log.Fatal("Error starting server: ", err)
        }
}
