package main

import (
	"testing"
)

func TestGeneratePaginationLinks(t *testing.T) {
	actors := []string{"1.1.1.1","1.1.1.2",	"1.1.1.3","1.1.1.4","1.1.1.5"}
	pages := GeneratePaginationLinks(actors, 1, 0, "blacklist")
	if len(pages) != 5 {
		t.Error("Expected 5 pages, got:", len(pages))
	}

	if pages["5"] != "/blacklist?page=5" {
		t.Error("Expected /blacklist?page=5, got:", pages["5"])
	}
}
