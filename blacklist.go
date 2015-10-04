package main

import (
	"html/template"
	"net/http"
)

func BlacklistHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")

        err := request.ParseForm()
        if err != nil {
		http.Redirect(response, request, "/error", 307)
        }

        blacklisted  := replyToArray(configuration.Redis.Connection.Cmd("KEYS", "*:repsheet:ip:blacklisted"))
        templates, _ := template.ParseFiles("templates/layout.html", "templates/blacklist.html")
        summary      := Summary{Blacklisted: blacklisted}
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "blacklist"})

	return 200, nil
}
