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
        "allow"
      end
    end

    def h(text)
      Rack::Utils.escape_html(text)
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
    erb :actors
  end

  get '/whitelist' do
    @whitelist = Backend.whitelist(redis_connection)
    erb :whitelist
  end

  get '/breakdown' do
    @data = Backend.breakdown(redis_connection)
    erb :breakdown
  end

  get '/worldview' do
    @data = Backend.worldview(redis_connection, geoip_database)
    erb :worldview
  end

  get '/activity/:ip' do
    @ip = params[:ip]
    @data = Backend.activity(redis_connection, @ip)
    @action = action(@ip)
    erb :activity
  end

  post '/action' do
    connection = redis_connection
    if params["action"] == "allow"
      connection.del("#{params[:ip]}:repsheet:blacklist")
    else
      ttl = connection.ttl("#{params[:ip]}:requests")
      connection.set("#{params[:ip]}:repsheet:blacklist", "true")
      connection.expire("#{params[:ip]}:repsheet:blacklist", ttl)
    end
    redirect back
  end
end
