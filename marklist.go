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
                http.Error(response, fmt.Sprintf("error parsing url %v", err), 500)
        }
        connection := connect(configuration.Redis.Host, configuration.Redis.Port)
        marked := replyToArray(connection.Cmd("KEYS", "*:repsheet:ip:marked"))
        templates, _ := template.ParseFiles("layout.html", "marklist.html")
        summary := Summary{Marked: marked}
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "marklist"})
	return 200, nil
}
