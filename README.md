#Repsheet Visualizer [![Build Status](https://secure.travis-ci.org/repsheet/visualizer.png)](http://travis-ci.org/repsheet/visualizer?branch=master)

This is the visualization component for Repsheet. It displays information on offending actors and allows for manual blacklisting. It provides a world map that displays the location of offending actors which allows for identification of global attack patterns. It is still under active development and will undergo some pretty major changes over the next several months.

## Setup

You will need to have Ruby/RubyGems installed. If you would like to use the world map feature, you will need a copy of the [GeoLiteCity Database](http://geolite.maxmind.com/download/geoip/database/GeoLiteCity.dat.gz). This app has been tested on Ruby 1.9.3 Ruby 2.0.0. You will also need access to the Repsheet Redis database. There are several ways of running the Visualizer application, but the simplest is to just run the command line program:

``` sh
bundle install
bin/repsheet_visualizer <redis_host> <redis_port> <path_to_geolite_database>
```

Visit [http://localhost:4567](http://localhost:4567) to view the application
