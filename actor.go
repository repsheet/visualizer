package main

import (
        "fmt"
        "strings"
        "html/template"
        "net/http"
        "github.com/gorilla/mux"
        "github.com/fzzy/radix/redis"
        "github.com/abh/geoip"
)

type Actor struct {
        Id          string
        Whitelisted bool
        Blacklisted bool
        Marked      bool
        GeoIP       *geoip.GeoIPRecord
}

type Summary struct {
        Blacklisted []string
        Whitelisted []string
        Marked      []string
}

func geoipLookup(configuration *Configuration, actor string) *geoip.GeoIPRecord {
        gi, err := geoip.Open(configuration.GeoIPDatabase)
        if err != nil {
                fmt.Printf("GeoIP: Could not open %s\n", configuration.GeoIPDatabase)
                return &geoip.GeoIPRecord{}
        }

        return gi.GetRecord(actor)
}

func makeActor(id string, reply *redis.Reply, geo *geoip.GeoIPRecord) Actor {
        var actor Actor
        actor.Id = id
        actor.GeoIP = geo
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
                http.Redirect(response, request, "/error", 307)
        }

        vars         := mux.Vars(request)
        geo          := geoipLookup(configuration, vars["id"])
        actorString  := fmt.Sprintf("%s:repsheet:ip:*", vars["id"])
        actor        := makeActor(vars["id"], configuration.Redis.Connection.Cmd("KEYS", actorString), geo)

        templates, _ := template.ParseFiles("templates/layout.html", "templates/actor.html")
        templates.ExecuteTemplate(response, "layout", Page{Actor: actor})

        return 200, nil
}
