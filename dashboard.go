package main

import (
	"fmt"
	"html/template"
	"net/http"
)

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
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "dashboard"})
}
