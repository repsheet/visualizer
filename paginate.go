package main

import (
	"fmt"
	"strconv"
)

func GeneratePaginationLinks(actors []string, limit int, offset int, uri string) map[string]string {
	links := make(map[string]string)
	last_page := len(actors) / limit
	for i := 1; i < last_page; i++ {
		link := fmt.Sprintf("%s?page=%d", uri, i)
		links[strconv.Itoa(i)] = link
	}
	links[strconv.Itoa(last_page)] = fmt.Sprintf("/%s?page=%d", uri, last_page)
	return links
}
