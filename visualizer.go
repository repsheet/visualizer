package main

import (
        "log"
        "fmt"
        "github.com/gorilla/mux"
        "github.com/gorilla/handlers"
        "html/template"
        "net/http"
        "os"
)

type Page struct {
        Title string
}

var templates = template.Must(template.ParseFiles("index.html"))

func IndexHandler(response http.ResponseWriter, request *http.Request) {
        response.Header().Set("Content-type", "text/html")
        err := request.ParseForm()
        if err != nil {
                http.Error(response, fmt.Sprintf("error parsing url %v", err), 500)
        }
        templates.ExecuteTemplate(response, "index.html", Page{Title: "Index"})
}

func main() {
	logFile, err := os.OpenFile("logs/app.log", os.O_WRONLY | os.O_CREATE | os.O_APPEND, 0666)
	if err != nil {
		fmt.Println("Error accessing log file:", err)
		os.Exit(1)
	}

        r := mux.NewRouter()
        r.Handle("/", handlers.LoggingHandler(logFile, http.HandlerFunc(IndexHandler)))
        r.PathPrefix("/public/").Handler(http.StripPrefix("/public/", http.FileServer(http.Dir("public"))))
        http.Handle("/", r)

        err = http.ListenAndServe("localhost:8080", r)
        if err != nil {
                log.Fatal("Error starting server: ", err)
        }
}

