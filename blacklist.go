package main

import (
        "html/template"
        "net/http"
        "strconv"
)

func BlacklistHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")

        err := request.ParseForm()
        if err != nil {
                http.Redirect(response, request, "/error", 307)
        }

        params := request.URL.Query()
        var page int
        if len(params["page"]) <= 0 {
                page = 0
        } else {
                page, _ = strconv.Atoi(params["page"][0])
        }

        connection   := connect(configuration.Redis.Host, configuration.Redis.Port)

        blacklist    := connection.Cmd("KEYS", "*:repsheet:ip:blacklisted")
        blacklisted  := Paginate(configuration, blacklist, page, 10)
        templates, _ := template.ParseFiles(
                configuration.TemplateFor("layout"),
                configuration.TemplateFor("pagination"),
                configuration.TemplateFor("blacklist"),
        )
        summary      := Summary{Blacklisted: blacklisted}
        pagination   := GeneratePaginationLinks(blacklist, 10, 0, "/blacklist")
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "blacklist", Pagination: pagination})

        return 200, nil
}
