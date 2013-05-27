require 'geoip'
require 'sinatra'
require 'redis'
require 'json'

class RepsheetVisualizer < Sinatra::Base
  helpers do
    def action(data)
      if data[:blacklist].nil? || data[:blacklist] == "false"
        "blacklist"
      else
        "allow"
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

  get '/' do
    redis = redis_connection
    data = redis.keys("*:requests").map {|d| d.split(":").first}.reject {|ip| ip.empty?}
    @actors = {}
    data.each do |actor|
      @actors[actor] = {}
      @actors[actor][:repsheet] = redis.get("#{actor}:repsheet")
      @actors[actor][:blacklist] = redis.get("#{actor}:repsheet:blacklist")
      @actors[actor][:detected] = redis.smembers("#{actor}:detected").join(", ")
    end
    @mount = mount
    erb :actors
  end

  get '/activity/:ip' do
    redis = redis_connection
    @ip = params[:ip]
    @activity = redis.lrange("#{@ip}:requests", 0, -1)
    @mount = mount
    erb :activity
  end

  post '/action' do
    redis = redis_connection
    if params["action"] == "allow"
      redis.set("#{params[:ip]}:repsheet:blacklist", "false")
    else
      redis.set("#{params[:ip]}:repsheet:blacklist", "true")
    end
    @mount = mount
    redirect back
  end

  get '/breakdown' do
    redis = redis_connection
    @data = {}
    offenders = redis.keys("*:repsheet").map {|o| o.split(":").first}
    offenders.each do |offender|
      @data[offender] = {"totals" => {}}
      redis.smembers("#{offender}:detected").each do |rule|
        @data[offender]["totals"][rule] = redis.get "#{offender}:#{rule}:count"
      end
    end
    @aggregate = Hash.new 0
    @data.each {|ip,data| data["totals"].each {|rule,count| @aggregate[rule] += count.to_i}}
    @mount = mount
    erb :breakdown
  end

  get '/worldview' do
    db = geoip_database
    redis = redis_connection
    @data = {}
    offenders = redis.keys("*:repsheet*").map {|o| o.split(":").first}
    offenders.each do |address|
      details = db.country(address)
      @data[address] = [details.latitude, details.longitude]
    end
    erb :worldview
  end
end
