package main

import (
	"fmt"
	"html/template"
	"net/http"
)

func BlacklistHandler(response http.ResponseWriter, request *http.Request) {
        response.Header().Set("Content-type", "text/html")
        err := request.ParseForm()
        if err != nil {
                http.Error(response, fmt.Sprintf("error parsing url %v", err), 500)
        }
        connection := connect("localhost", 6379)
        blacklisted := replyToArray(connection.Cmd("KEYS", "*:repsheet:ip:blacklisted"))
        templates, _ := template.ParseFiles("layout.html", "blacklist.html")
        summary := Summary{Blacklisted: blacklisted}
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "blacklist"})
}
