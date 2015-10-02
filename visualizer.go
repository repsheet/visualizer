package main

import (
        "log"
        "fmt"
        "html/template"
        "net/http"
        "os"
	"github.com/gorilla/mux"
        "github.com/gorilla/handlers"
)

type Summary struct {
	Blacklisted []string
	Whitelisted []string
	Marked      []string
	Total       int
}

type Page struct {
        Title string
	Summary Summary
}

func DashboardHandler(response http.ResponseWriter, request *http.Request) {
        response.Header().Set("Content-type", "text/html")
        err := request.ParseForm()
        if err != nil {
                http.Error(response, fmt.Sprintf("error parsing url %v", err), 500)
        }
	templates, _ := template.ParseFiles("layout.html", "index.html")
	summary := Summary{Blacklisted: []string{"1.1.1.1", "1.1.1.2"}, Whitelisted: []string{"2.2.2.1", "2.2.2.2"}, Marked: []string{"3.3.3.1", "3.3.3.2"}, Total: 6}
        templates.ExecuteTemplate(response, "layout", Page{Title: "Dashboard", Summary: summary})
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

