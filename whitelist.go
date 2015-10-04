package main

import (
	"fmt"
	"html/template"
	"net/http"
)

func WhitelistHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")

        err := request.ParseForm()
        if err != nil {
                http.Error(response, fmt.Sprintf("error parsing url %v", err), 500)
        }

        whitelisted  := replyToArray(configuration.Redis.Connection.Cmd("KEYS", "*:repsheet:ip:whitelisted"))
        templates, _ := template.ParseFiles("layout.html", "whitelist.html")
        summary      := Summary{Whitelisted: whitelisted}
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "whitelist"})

	return 200, nil
}
