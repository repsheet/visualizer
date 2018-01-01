local redis = require 'resty.redis'
local json = require 'json'

function split(str, sep)
    local words = {}
    for w in string.gmatch(str, sep) do 
        table.insert(words, w) 
    end
    return words
end

function blacklist()
    local connection = redis:new()
    local ok, err = connection.connect("visualizer-redis", 6379)
    if not ok then
        ngx.say("Failed to connect: ", err)
        return
    end

    local response, err = connection:keys("*:repsheet:ip:blacklisted")
    if not ok then
        ngx.say("Failed to get keys: ", err)
        return
    end

    for k,v in pairs(response) do
        local parts = split(v, "[^:]+")
        response[k] = parts[1]
    end
    
    local t = {}
    t["blacklist"] = response
    
    ngx.say(json.encode(t))
    return
end

blacklist()