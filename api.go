package main

import (
        "encoding/json"
        "net/http"
)

func ApiBlacklistHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        connection := connect(configuration.Redis.Host, configuration.Redis.Port)
        blacklist := replyToMap(configuration, connection.Cmd("KEYS", "*:repsheet:ip:blacklisted"))

        data, err := json.Marshal(blacklist)
        if err != nil {
                http.Error(response, err.Error(), http.StatusInternalServerError)
                return 500, err
        }

        response.Header().Set("Content-type", "application/json")
        response.Write(data)

        return 200, nil
}

func ApiWhitelistHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        connection := connect(configuration.Redis.Host, configuration.Redis.Port)
        whitelist := replyToMap(configuration, connection.Cmd("KEYS", "*:repsheet:ip:whitelisted"))

        data, err := json.Marshal(whitelist)
        if err != nil {
                http.Error(response, err.Error(), http.StatusInternalServerError)
                return 500, err
        }

        response.Header().Set("Content-type", "application/json")
        response.Write(data)

        return 200, nil
}

func ApiMarklistHandler(configuration *Configuration, response http.ResponseWriter, request *http.Request) (int, error) {
        connection := connect(configuration.Redis.Host, configuration.Redis.Port)
        marklist := replyToMap(configuration, connection.Cmd("KEYS", "*:repsheet:ip:marked"))

        data, err := json.Marshal(marklist)
        if err != nil {
                http.Error(response, err.Error(), http.StatusInternalServerError)
                return 500, err
        }

        response.Header().Set("Content-type", "application/json")
        response.Write(data)

        return 200, nil
}
