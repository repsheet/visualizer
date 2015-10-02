package main

import (
	"fmt"
	"html/template"
	"net/http"
)

func WhitelistHandler(response http.ResponseWriter, request *http.Request) {
        response.Header().Set("Content-type", "text/html")
        err := request.ParseForm()
        if err != nil {
                http.Error(response, fmt.Sprintf("error parsing url %v", err), 500)
        }
        connection := connect("localhost", 6379)
        whitelisted := replyToArray(connection.Cmd("KEYS", "*:repsheet:ip:whitelisted"))
        templates, _ := template.ParseFiles("layout.html", "whitelist.html")
        summary := Summary{Whitelisted: whitelisted}
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary})
}
