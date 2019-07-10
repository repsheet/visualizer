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
   local ok, err = red:connect("127.0.0.1", 6379)
   if not ok then
      ngx.say("Failed to connect: ", err)
      return
   end

   local status, err = red["repsheet.status"](red, "1.1.1.1")
   if not status then
      ngx.say("Failed to get status: ", err)
      return
   end

   local response = cjson.encode({
         status = status
   })

   ngx.say(response)

   return
end

actor()
