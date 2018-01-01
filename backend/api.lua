local json = require 'json'
local redis = require 'resty.redis'

function redis.status()
    local red = redis:new()
    local ok, err = red:connect("127.0.0.1", 6379)
    if not ok then
        return err
    end

    local response, err = red:ping()
    if not ok then
        return err
    end

    return response
end

function status()
    t = {}
    t["status"] = "OK"
    t["redis"] = redis.status()
    
    ngx.say(json.encode(t))
    return
end

status()
