local redis = require 'redis'
local json = require 'json'

function split(str, sep)
    local words = {}
    for w in string.gmatch(str, sep) do 
        table.insert(words, w) 
    end
    return words
end

function blacklist()
    local client = redis.connect('127.0.0.1', 6379)
    local response = client:keys("*:repsheet:ip:blacklisted")

    for k,v in pairs(response) do
        local parts = split(v, "[^:]+")
        response[k] = parts[1]
    end
    
    local t = {}
    t["blacklist"] = response
    
    print(json.encode(t))    
end

blacklist()