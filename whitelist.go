package main

import (
        "html/template"
        "net/http"
)

func WhitelistHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")

        err := request.ParseForm()
        if err != nil {
                http.Redirect(response, request, "/error", 307)
        }

        connection := connect(configuration.Redis.Host, configuration.Redis.Port)

        whitelisted  := replyToArray(connection.Cmd("KEYS", "*:repsheet:ip:whitelisted"))
        templates, _ := template.ParseFiles("templates/layout.html", "templates/whitelist.html")
        summary      := Summary{Whitelisted: whitelisted}
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "whitelist"})

        return 200, nil
}
