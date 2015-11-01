package main

import (
        "fmt"
        "strconv"
        "github.com/fzzy/radix/redis"
        "strings"
        "math"
)

func calculateEnd(start int, limit int, size int) int {
        end := start + limit
        if end > size {
                return size
        } else {
                return end
        }
}

func calculateStart(page int, limit int, size int) int {
        if page == 0 || page == 1 {
                return 0
        } else {
                start := page * limit - limit
                if start > size {
                        return 0
                } else {
                        return start
                }
        }
}

func Paginate(configuration *Configuration, reply *redis.Reply, page int, limit int) []Actor {
        connection := connect(configuration.Redis.Host, configuration.Redis.Port)

        var actors []Actor
        start := calculateStart(page, limit, len(reply.Elems))
        end   := calculateEnd(start, limit, len(reply.Elems))
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
        last_page := int(math.Ceil(float64(len(actors.Elems)) / float64(limit)))
        for i := 1; i < last_page; i++ {
                link := fmt.Sprintf("%s?page=%d", uri, i)
                links[strconv.Itoa(i)] = link
        }
        links[strconv.Itoa(last_page)] = fmt.Sprintf("%s?page=%d", uri, last_page)
        return links
}
