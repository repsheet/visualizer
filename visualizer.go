package main

import (
        "log"
        "fmt"
        "net/http"
        "os"
        "github.com/gorilla/mux"
        "github.com/gorilla/handlers"
)

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
        logFile, err := os.OpenFile("logs/app.log", os.O_WRONLY | os.O_CREATE | os.O_APPEND, 0666)
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

        err = http.ListenAndServe("localhost:8080", r)
        if err != nil {
                log.Fatal("Error starting server: ", err)
        }
}
