package main

import (
	"fmt"
	"html/template"
	"net/http"
)

func MarklistHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")

        err := request.ParseForm()
        if err != nil {
		http.Redirect(response, request, "/error", 307)
        }

        marked       := replyToArray(configuration.Redis.Connection.Cmd("KEYS", "*:repsheet:ip:marked"))
        templates, _ := template.ParseFiles("templates/layout.html", "templates/marklist.html")
        summary      := Summary{Marked: marked}
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "marklist"})

	return 200, nil
}
