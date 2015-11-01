package main

import (
        "testing"
)

func PopulateRedis() {
        connection := connect("localhost", 6379)
        connection.Cmd("FLUSHDB")
        connection.Cmd("SET", "1.1.1.1:repsheet:ip:blacklisted", "test")
        connection.Cmd("SET", "1.1.1.2:repsheet:ip:blacklisted", "test")
        connection.Cmd("SET", "1.1.1.3:repsheet:ip:blacklisted", "test")
        connection.Cmd("SET", "1.1.1.4:repsheet:ip:blacklisted", "test")
        connection.Cmd("SET", "1.1.1.5:repsheet:ip:blacklisted", "test")
        connection.Close()
}

func TestGeneratePaginationLinks(t *testing.T) {
        PopulateRedis()
        connection := connect("localhost", 6379)
        actors := connection.Cmd("KEYS", "*:repsheet:ip:blacklisted")
        pages := GeneratePaginationLinks(actors, 1, 0, "blacklist")
        if len(pages) != 5 {
                t.Error("Expected 5 pages, got:", len(pages))
        }

        if pages["5"] != "blacklist?page=5" {
                t.Error("Expected blacklist?page=5, got:", pages["5"])
        }
}
