package main

import "net/http"

type Configuration struct {
	Redis         Redis
	LogFile       string
	Port          int
	GeoIPDatabase string
}

type configurationHandler struct {
	*Configuration
	h func(*Configuration, http.ResponseWriter, *http.Request) (int, error)
}

func (h configurationHandler) ServeHTTP(w http.ResponseWriter, r *http.Request) {
	h.h(h.Configuration, w, r)
}
