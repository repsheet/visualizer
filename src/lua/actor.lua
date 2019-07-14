local redis = require 'resty.redis'
local cjson = require 'cjson'

function split(str, sep)
   local words = {}
   for w in string.gmatch(str, sep) do
      table.insert(words, w)
   end
   return words
end

function actor()
   redis.add_commands("repsheet.status")
   local red = redis:new()
   local ok, err = red:connect(ngx.var.redis_host, ngx.var.redis_port)
   if not ok then
      ngx.say("Failed to connect: ", err)
      return
   end

   local address = ngx.var.arg_address

   local status, err = red["repsheet.status"](red, address)
   if not status then
      ngx.say("Failed to get status: ", err)
      return
   end

   local request_count = red:llen(address .. ":repsheet:requests")
   if not request_count then
      ngx.say("Failed to get request count: ", err)
   end

   local requests = red:lrange(address .. ":repsheet:requests", 0, -1)
   if not requests then
      ngx.say("Failed to get requests ", err)
   end

   local response = cjson.encode({
         status = status,
	 request_count = request_count,
	 requests = requests
   })

   ngx.say(response)

   return
end

actor()
