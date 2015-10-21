package main

import (
        "html/template"
        "net/http"
)

func DashboardHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")

        err := request.ParseForm()
        if err != nil {
                http.Redirect(response, request, "/error", 307)
        }

        connection := connect(configuration.Redis.Host, configuration.Redis.Port)

        blacklisted  := replyToActors(configuration, connection.Cmd("KEYS", "*:repsheet:ip:blacklisted"))
        whitelisted  := replyToActors(configuration, connection.Cmd("KEYS", "*:repsheet:ip:whitelisted"))
        marked       := replyToActors(configuration, connection.Cmd("KEYS", "*:repsheet:ip:marked"))
        templates, _ := template.ParseFiles(configuration.TemplateFor("layout"), configuration.TemplateFor("dashboard"))
        summary      := Summary{Blacklisted: blacklisted, Whitelisted: whitelisted, Marked: marked}
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "dashboard"})

        return 200, nil
}
