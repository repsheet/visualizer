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

type Page struct {
        Title string
        Summary Summary
}

func main() {
        logFile, err := os.OpenFile("logs/app.log", os.O_WRONLY | os.O_CREATE | os.O_APPEND, 0666)
        if err != nil {
                fmt.Println("Error accessing log file:", err)
                os.Exit(1)
        }

        r := mux.NewRouter()
        r.Handle("/", handlers.LoggingHandler(logFile, http.HandlerFunc(DashboardHandler)))
        r.PathPrefix("/public/").Handler(http.StripPrefix("/public/", http.FileServer(http.Dir("public"))))
        http.Handle("/", r)

        err = http.ListenAndServe("localhost:8080", r)
        if err != nil {
                log.Fatal("Error starting server: ", err)
        }
}
