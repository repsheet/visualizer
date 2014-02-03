require 'repsheet_visualizer'

RepsheetVisualizer::App.set :redis_host, "localhost"
RepsheetVisualizer::App.set :redis_port, 6379
RepsheetVisualizer::App.set :geoip_database, "/Users/abedra/src/opensource/repsheet/vendor/geoip/GeoLiteCity.dat"

run RepsheetVisualizer::App

