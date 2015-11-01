package main

import (
        "fmt"
        "strconv"
        "github.com/fzzy/radix/redis"
        "strings"
)

func calculateLimit(page int, limit int, size int) int {
        end := page * limit + limit
        if end > size {
                return size
        } else {
                return end
        }
}

func Paginate(configuration *Configuration, reply *redis.Reply, page int, limit int) []Actor {
        connection := connect(configuration.Redis.Host, configuration.Redis.Port)

        var actors []Actor
        start := page * limit
        end := calculateLimit(page, limit, len(reply.Elems))
        for i := start; i < end; i++ {
                actor, _ := reply.Elems[i].Str()
                reason := connection.Cmd("GET", actor)
                reasonString, _ := reason.Str()
                actors = append(actors, Actor{Id: strings.Split(actor, ":")[0], Reason: reasonString})
        }

        return actors
}

func GeneratePaginationLinks(actors *redis.Reply, limit int, offset int, uri string) map[string]string {
        links := make(map[string]string)
        last_page := len(actors.Elems) / limit
        for i := 1; i < last_page; i++ {
                link := fmt.Sprintf("%s?page=%d", uri, i)
                links[strconv.Itoa(i)] = link
        }
        links[strconv.Itoa(last_page)] = fmt.Sprintf("%s?page=%d", uri, last_page)
        return links
}
