package main

import (
	"fmt"
	"html/template"
	"net/http"
)

func DashboardHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")

        err := request.ParseForm()
        if err != nil {
                http.Error(response, fmt.Sprintf("error parsing url %v", err), 500)
        }

        blacklisted  := replyToArray(configuration.Redis.Connection.Cmd("KEYS", "*:repsheet:ip:blacklisted"))
	whitelisted  := replyToArray(configuration.Redis.Connection.Cmd("KEYS", "*:repsheet:ip:whitelisted"))
	marked       := replyToArray(configuration.Redis.Connection.Cmd("KEYS", "*:repsheet:ip:marked"))
        templates, _ := template.ParseFiles("layout.html", "dashboard.html")
        summary      := Summary{Blacklisted: blacklisted, Whitelisted: whitelisted, Marked: marked}
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "dashboard"})

	return 200, nil
}
