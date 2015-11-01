package main

import (
        "html/template"
        "net/http"
        "strconv"
)

func WhitelistHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
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

        var currentPage string
        if page == 0 || page == 1 {
                currentPage = "1"
        } else {
                currentPage = strconv.Itoa(page)
        }

        connection   := connect(configuration.Redis.Host, configuration.Redis.Port)

        whitelist    := connection.Cmd("KEYS", "*:repsheet:ip:whitelisted")
        whitelisted  := Paginate(configuration, whitelist, page, 10)
        templates, _ := template.ParseFiles(
                configuration.TemplateFor("layout"),
                configuration.TemplateFor("pagination"),
                configuration.TemplateFor("whitelist"),
        )
        summary      := Summary{Whitelisted: whitelisted}
        pagination   := GeneratePaginationLinks(whitelist, 10, 0, "/whitelist")
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "whitelist", Pagination: pagination, CurrentPage: currentPage})

        return 200, nil
}
