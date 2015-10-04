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
	Connection *redis.Client
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

