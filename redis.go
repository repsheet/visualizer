package main

import (
        "fmt"
        "syscall"
        "os"
        "strings"
        "github.com/fzzy/radix/redis"
)

type Redis struct {
        Host string
        Port int
}

func connect(host string, port int) *redis.Client {
        connectionString := fmt.Sprintf("%s:%d", host, port)
        conn, err := redis.Dial("tcp", connectionString)

        if err != nil {
                fmt.Println("Cannot connect to Redis, exiting.")
                os.Exit(int(syscall.ECONNREFUSED))
        }

        return conn
}

func replyToArray(reply *redis.Reply) []string {
        var results []string

        for i := 0; i < len(reply.Elems); i++ {
                s, _ := reply.Elems[i].Str()
                results = append(results, strings.Split(s, ":")[0])
        }

        return results
}

func replyToActors(configuration *Configuration, reply *redis.Reply) []Actor {
        var actors []Actor
        connection := connect(configuration.Redis.Host, configuration.Redis.Port)
        for i := 0; i < len(reply.Elems); i++ {
                actor, _ := reply.Elems[i].Str()
                reason := connection.Cmd("GET", actor)
                reasonString, _ := reason.Str()
                actors = append(actors, Actor{Id: strings.Split(actor, ":")[0], Reason: reasonString})
        }

        return actors
}

func arrayToActors(configuration *Configuration, actors []string) []Actor {
        var list []Actor
        connection := connect(configuration.Redis.Host, configuration.Redis.Port)
        for _, a := range actors {
                reason := connection.Cmd("GET", a)
                reasonString, _ := reason.Str()
                list = append(list, Actor{Id: a, Reason: reasonString})
        }

        return list
}
