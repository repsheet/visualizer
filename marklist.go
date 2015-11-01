package main

import (
        "html/template"
        "net/http"
)

func MarklistHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")

        err := request.ParseForm()
        if err != nil {
                http.Redirect(response, request, "/error", 307)
        }

        connection := connect(configuration.Redis.Host, configuration.Redis.Port)

        marklist     := connection.Cmd("KEYS", "*:repsheet:ip:marked")
        marked       := Paginate(configuration, marklist, 0, 10)
        templates, _ := template.ParseFiles(
                configuration.TemplateFor("layout"),
                configuration.TemplateFor("pagination"),
                configuration.TemplateFor("marklist"),
        )
        summary      := Summary{Marked: marked}
        pagination   := GeneratePaginationLinks(marklist, 10, 0, "/marklist")
        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "marklist", Pagination: pagination})

        return 200, nil
}
