require 'geoip'
require 'sinatra'
require 'redis'
require 'json'
require_relative 'backend'

class RepsheetVisualizer < Sinatra::Base
  before do
    @mount = mount
  end

  helpers do
    def action(ip, blacklist=nil)
      blacklist = redis_connection.get("#{ip}:repsheet:blacklist") if blacklist.nil?
      if blacklist.nil? || blacklist == "false"
        "blacklist"
      else
        "whitelist"
      end
    end

    def replace_invalid_chars(str)
      str.encode('UTF-16le', :invalid => :replace, :replace => '?').encode('UTF-8')
    end

    def h(text)
      begin
        Rack::Utils.escape_html(text)
      rescue ArgumentError
        replace_invalid_chars(text)
      end
    end
  end

  def redis_connection
    host = defined?(settings.redis_host) ? settings.redis_host : "localhost"
    port = defined?(settings.redis_port) ? settings.redis_port : 6379
    Redis.new(:host => host, :port => port)
  end

  def geoip_database
    geoip_database = defined?(settings.geoip_database) ? settings.geoip_database : nil
    raise "Missing GeoIP database settings" if geoip_database.nil?
    raise "Could not locate GeoIP database" unless File.exist?(geoip_database)
    GeoIP.new(settings.geoip_database)
  end

  def mount
    defined?(settings.mount) ? (settings.mount + "/") : "/"
  end

  def redis_expiry
    defined?(settings.redis_expiry) ? (settings.redis_expiry * 60 * 60) : (24 * 60 * 60)
  end

  get '/' do
    @suspects, @blacklisted = Backend.summary(redis_connection)
    @whitelist = Backend.whitelist(redis_connection)
    @blacklist_total = Backend.blacklist_total(redis_connection)
    erb :index
  end

  get '/whitelist' do
    @whitelist = Backend.whitelist(redis_connection)
    erb :whitelist
  end

  get '/blacklist' do
    @blacklist = Backend.blacklist(redis_connection)
    erb :blacklist
  end

  get '/suspects' do
    @suspects, _ = Backend.suspects(redis_connection)
    erb :suspects
  end

  get '/breakdown' do
    @data = Backend.breakdown(redis_connection)
    erb :breakdown
  end

  get '/worldview' do
    @data = Backend.worldview(redis_connection, geoip_database)
    erb :worldview
  end

  get '/actors/:ip' do
    @ip = params[:ip]
    @activity = Backend.activity(redis_connection, @ip)
    triggered = Backend.triggered_rules(redis_connection, @ip)
    offenses = Backend.score_actor(redis_connection, @ip, triggered, false)
    @modsecurity = {:triggered => triggered.join(", "), :offenses => offenses}
    @ofdp_score = Backend.ofdp_score(redis_connection, @ip) || 0
    @whitelisted = Backend.whitelisted?(redis_connection, @ip)
    @blacklisted = Backend.blacklisted?(redis_connection, @ip)

    details = geoip_database.country(@ip)
    unless details.nil?
      @lat = details.latitude
      @lng = details.longitude
      @country = details.country_name
      @region = details.region_name
      @city = details.city_name
    end

    @action = action(@ip)
    erb :actor
  end

  post '/action' do
    connection = redis_connection
    if params["action"] == "whitelist"
      connection.set("#{params[:ip]}:repsheet:whitelist", "true")
      connection.del("#{params[:ip]}:repsheet:blacklist")
      connection.del("#{params[:ip]}:repsheet")
      connection.del("#{params[:ip]}:detected")
      connection.srem("repsheet:blacklist:history", params[:ip])
    elsif params["action"] == "blacklist"
      ttl = connection.ttl("#{params[:ip]}:requests")
      connection.setex("#{params[:ip]}:repsheet:blacklist", ttl, "true")
      connection.sadd("repsheet:blacklist:history", params[:ip])
      connection.del("#{params[:ip]}:repsheet:whitelist")
    end
    redirect back
  end
end
