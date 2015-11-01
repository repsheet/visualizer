package main

import (
        "fmt"
        "net/http"
)

type Configuration struct {
        Redis         Redis
        LogFile       string
        Port          int
        GeoIPDatabase string
        AssetsDir     string
}

type configurationHandler struct {
        *Configuration
        h func(*Configuration, http.ResponseWriter, *http.Request) (int, error)
}

func (h configurationHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
        h.h(h.Configuration, w, r)
}

func (c Configuration) TemplateFor(name string) string {
        return fmt.Sprintf("%s/templates/%s.html", c.AssetsDir, name)
}
