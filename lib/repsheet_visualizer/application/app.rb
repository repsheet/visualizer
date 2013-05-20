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

  get '/' do
    redis = Redis.new(:host => "localhost", :port => 6379)
    data = redis.keys("*:requests").map {|d| d.split(":").first}.reject {|ip| ip.empty?}
    @actors = {}
    data.each do |actor|
      @actors[actor] = {}
      @actors[actor][:repsheet] = redis.get("#{actor}:repsheet")
      @actors[actor][:blacklist] = redis.get("#{actor}:repsheet:blacklist")
      @actors[actor][:detected] = redis.smembers("#{actor}:detected").join(", ")
    end
    erb :actors
  end

  get '/activity/:ip' do
    redis = Redis.new(:host => "localhost", :port => 6379)
    @ip = params[:ip]
    @activity = redis.lrange("#{@ip}:requests", 0, -1)
    erb :activity
  end

  post '/action' do
    redis = Redis.new(:host => "localhost", :port => 6379)
    if params["action"] == "allow"
      redis.set("#{params[:ip]}:repsheet:blacklist", "false")
    else
      redis.set("#{params[:ip]}:repsheet:blacklist", "true")
    end
    redirect back
  end

  get '/breakdown' do
    redis = Redis.new(:host => "localhost", :port => 6379)
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
    erb :breakdown
  end
end
