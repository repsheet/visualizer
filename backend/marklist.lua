local redis = require 'resty.redis'
local json = require 'json'

function split(str, sep)
    local words = {}
    for w in string.gmatch(str, sep) do 
        table.insert(words, w) 
    end
    return words
end

function marklist()
    local red = redis:new()
    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
        ngx.say("Failed to connect: ", err)
        return
    end

    local response, err = red:keys("*:repsheet:ip:marked")
    if not ok then
        ngx.say("Failed to get keys: ", err)
        return
    end

    for k,v in pairs(response) do
        local parts = split(v, "[^:]+")
        response[k] = parts[1]
    end
    
    local t = {}
    t["marklist"] = response
    
    ngx.say(json.encode(t))
    return
end

marklist()