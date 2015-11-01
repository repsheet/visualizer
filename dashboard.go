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

        blacklist    := connection.Cmd("KEYS", "*:repsheet:ip:blacklisted")
        blacklisted  := Paginate(configuration, blacklist, 0, 10)
        whitelist    := connection.Cmd("KEYS", "*:repsheet:ip:whitelisted")
        whitelisted  := Paginate(configuration, whitelist, 0, 10)
        marklist     := connection.Cmd("KEYS", "*:repsheet:ip:marked")
        marked       := Paginate(configuration, marklist, 0, 10)
        templates, _ := template.ParseFiles(configuration.TemplateFor("layout"), configuration.TemplateFor("dashboard"))

        totals := make(map[string]int)
        totals["blacklist"] = len(blacklist.Elems)
        totals["whitelist"] = len(whitelist.Elems)
        totals["marklist"]  = len(marklist.Elems)

        summary      := Summary {
                Blacklisted: blacklisted,
                Whitelisted: whitelisted,
                Marked: marked,
                Totals: totals,
        }

        templates.ExecuteTemplate(response, "layout", Page{Summary: summary, Active: "dashboard"})

        return 200, nil
}
