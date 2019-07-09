local redis = require 'resty.redis'
local cjson = require 'cjson'

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

   local marklist, err = red:keys("*:repsheet:ip:marked")
   if not ok then
      ngx.say("Failed to get keys: ", err)
      return
   end

   for k,v in pairs(marklist) do
      local parts = split(v, "[^:]+")
      marklist[k] = parts[1]
   end

   local response = cjson.encode({
	 marklist = marklist
   })

   ngx.say(response)

   return
end

marklist()
