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

        whitelist    := connection.Cmd("KEYS", "*:repsheet:ip:whitelisted")
        whitelisted  := Paginate(configuration, whitelist, 0, 10)
        templates, _ := template.ParseFiles(
                configuration.TemplateFor("layout"),
                configuration.TemplateFor("pagination"),
                configuration.TemplateFor("whitelist"),
        )
        summary      := Summary{Whitelisted: whitelisted}
        pagination   := GeneratePaginationLinks(whitelist, 10, 0, "/whitelisted")
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "whitelist", Pagination: pagination})

        return 200, nil
}
