package main

import (
        "log"
        "fmt"
        "net/http"
        "os"
	"flag"
        "github.com/gorilla/mux"
        "github.com/gorilla/handlers"
)

type Redis struct {
	Host string
	Port int
}

type Configuration struct {
	Redis   Redis
	LogFile string
	Port    int
}

type Summary struct {
        Blacklisted []string
        Whitelisted []string
        Marked      []string
}

type Actor struct {
	Id          string
	Whitelisted bool
	Blacklisted bool
	Marked      bool
}

type Page struct {
	Active  string
        Summary Summary
	Actor   Actor
}

func main() {
	logFilePtr := flag.String("logfile", "logs/visualizer.log", "Path to log file")
	redisHostPtr := flag.String("redisHost", "localhost", "Redis hostname")
	redisPortPtr := flag.Int("redisPort", 6379, "Redis port")
	portPtr := flag.Int("port", 8080, "Visualizer http port")
	flag.Parse()

	configuration := Configuration{
		LogFile: *logFilePtr,
		Port: *portPtr,
		Redis: Redis{Host: *redisHostPtr, Port: *redisPortPtr},
	}

	logFile, err := os.OpenFile(configuration.LogFile, os.O_WRONLY | os.O_CREATE | os.O_APPEND, 0666)
        if err != nil {
                fmt.Println("Error accessing log file:", err)
                os.Exit(1)
        }

        r := mux.NewRouter()
        r.Handle("/", handlers.LoggingHandler(logFile, http.HandlerFunc(DashboardHandler)))
	r.Handle("/blacklist", handlers.LoggingHandler(logFile, http.HandlerFunc(BlacklistHandler)))
	r.Handle("/whitelist", handlers.LoggingHandler(logFile, http.HandlerFunc(WhitelistHandler)))
	r.Handle("/marklist", handlers.LoggingHandler(logFile, http.HandlerFunc(MarklistHandler)))
	r.Handle("/actors/{id}", handlers.LoggingHandler(logFile, http.HandlerFunc(ActorHandler)))
        r.PathPrefix("/public/").Handler(http.StripPrefix("/public/", http.FileServer(http.Dir("public"))))
        http.Handle("/", r)

	serverString := fmt.Sprintf("localhost:%d", configuration.Port)
        err = http.ListenAndServe(serverString, r)
        if err != nil {
                log.Fatal("Error starting server: ", err)
        }
}
