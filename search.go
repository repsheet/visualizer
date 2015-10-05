package main

import (
        "fmt"
        "net/http"
        "html/template"
)

func search(configuration *Configuration, actor string) bool {
        searchString := fmt.Sprintf("%s:*", actor)
        results := configuration.Redis.Connection.Cmd("KEYS", searchString)

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

        query := request.PostFormValue("actor")
        found := search(configuration, query)

        if found {
                location := fmt.Sprintf("/actors/%s", query)
                http.Redirect(response, request, location, 307)
        } else {

                templates, _ := template.ParseFiles("templates/layout.html", "templates/search.html")
                templates.ExecuteTemplate(response, "layout", Page{Actor: Actor{Id: query}})
        }

	return 200, nil
}
