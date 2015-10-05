#Repsheet Visualizer [![Build Status](https://secure.travis-ci.org/repsheet/visualizer.png)](http://travis-ci.org/repsheet/visualizer?branch=master)

This is a simple web application for visualizing the Repsheet
cache. It allows the user to view any Repsheet information that is
currently available in the cache.

## Setup

```
$ go get github.com/repsheet/visualizer
```

## Configuration

The visualizer has several configuration options:

```
logFile   - The path to the file you want to log to. Note: directory must exist prior to start.
port      - The port you want the application to serve traffic on
geoIp     - The location of the Geo city database
redisHost - The hostname of the Repsheet cache
redisPort - The port number of the Repsheet cache
```

