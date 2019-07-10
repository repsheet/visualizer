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
   if not marklist then
      ngx.say("Failed to get keys: ", err)
      return
   end

   local marklist_with_reason = {}
   for k,v in pairs(marklist) do
      local parts = split(v, "[^:]+")
      local reason, err = red:get(v)
      if not reason then
	 ngx.say("Failed to get reason: ", err)
	 return
      end
      marklist_with_reason[parts[1]] = reason
   end

   local response = cjson.encode({
         marklist = marklist_with_reason
   })

   ngx.say(response)

   return
end

marklist()
