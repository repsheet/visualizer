local redis = require 'resty.redis'
local cjson = require 'cjson'

function redis.status()
   local red = redis:new()
   local ok, err = red:connect(ngx.var.redis_host, ngx.var.redis_port)
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
   local response = cjson.encode({
         status = "OK",
         redis = redis.status()
   })

   ngx.say(response)

   return
end

status()
