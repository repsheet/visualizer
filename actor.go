package main

import (
        "fmt"
	"strings"
        "html/template"
        "net/http"
	"github.com/gorilla/mux"
	"github.com/fzzy/radix/redis"
)

type Actor struct {
	Id          string
	Whitelisted bool
	Blacklisted bool
	Marked      bool
}

type Summary struct {
        Blacklisted []string
        Whitelisted []string
        Marked      []string
}

func makeActor(id string, reply *redis.Reply) Actor {
	var actor Actor
	actor.Id = id
	for i := 0; i < len(reply.Elems); i++ {
		s, _ := reply.Elems[i].Str()
		t := strings.Split(s, ":")[3]
		switch t {
		case "whitelisted": actor.Whitelisted = true
		case "blacklisted": actor.Blacklisted = true
		case "marked": actor.Marked = true
		}
	}
	return actor
}

func ActorHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        response.Header().Set("Content-type", "text/html")

        err := request.ParseForm()
        if err != nil {
                http.Error(response, fmt.Sprintf("error parsing url %v", err), 500)
        }

        vars         := mux.Vars(request)
        actorString  := fmt.Sprintf("%s:repsheet:ip:*", vars["id"])
        actor        := makeActor(vars["id"], configuration.Redis.Connection.Cmd("KEYS", actorString))
        templates, _ := template.ParseFiles("templates/layout.html", "templates/actor.html")
        templates.ExecuteTemplate(response, "layout", Page{Actor: actor})

	return 200, nil
}
