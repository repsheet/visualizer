package main

import (
        "fmt"
        "net/http"
        "html/template"
        "github.com/fzzy/radix/redis"
)

func search(connection *redis.Client, actor string) bool {
        searchString := fmt.Sprintf("%s:*", actor)
        results := connection.Cmd("KEYS", searchString)

        if len(results.Elems) == 1 {
                return true
        } else {
                return false
        }
}

func SearchHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")

        err := request.ParseForm()
        if err != nil {
                http.Redirect(response, request, "/error", 307)
        }

        connection := connect(configuration.Redis.Host, configuration.Redis.Port)

        query := request.PostFormValue("actor")
        found := search(connection, query)

        if found {
                location := fmt.Sprintf("/actors/%s", query)
                http.Redirect(response, request, location, 307)
        } else {

                templates, _ := template.ParseFiles(configuration.TemplateFor("layout"), configuration.TemplateFor("search"))
                templates.ExecuteTemplate(response, "layout", Page{Actor: Actor{Id: query}})
        }

        return 200, nil
}
