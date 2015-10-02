package main

import (
        "log"
        "fmt"
        "html/template"
        "net/http"
        "os"
        "syscall"
	"strings"
        "github.com/gorilla/mux"
        "github.com/gorilla/handlers"
        "github.com/fzzy/radix/redis"
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

func connect(host string, port int) *redis.Client {
        connectionString := fmt.Sprintf("%s:%d", host, port)
        conn, err := redis.Dial("tcp", connectionString)

        if err != nil {
                fmt.Println("Cannot connect to Redis, exiting.")
                os.Exit(int(syscall.ECONNREFUSED))
        }

        return conn
}

func replyToArray(reply *redis.Reply) []string {
        var results []string
        for i := 0; i < len(reply.Elems); i++ {
                s, _ := reply.Elems[i].Str()
                results = append(results, strings.Split(s, ":")[0])
        }
        return results
}

func DashboardHandler(response http.ResponseWriter, request *http.Request) {
        response.Header().Set("Content-type", "text/html")
        err := request.ParseForm()
        if err != nil {
                http.Error(response, fmt.Sprintf("error parsing url %v", err), 500)
        }
        connection := connect("localhost", 6379)
        blacklisted := replyToArray(connection.Cmd("KEYS", "*:repsheet:ip:blacklisted"))
	whitelisted := replyToArray(connection.Cmd("KEYS", "*:repsheet:ip:whitelisted"))
	marked := replyToArray(connection.Cmd("KEYS", "*:repsheet:ip:marked"))
        templates, _ := template.ParseFiles("layout.html", "index.html")
        summary := Summary{Blacklisted: blacklisted, Whitelisted: whitelisted, Marked: marked}
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
