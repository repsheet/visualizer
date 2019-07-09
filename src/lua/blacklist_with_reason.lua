local redis = require 'resty.redis'
local cjson = require 'cjson'

function split(str, sep)
   local words = {}
   for w in string.gmatch(str, sep) do
      table.insert(words, w)
   end
   return words
end

function blacklist()
   local red = redis:new()
   local ok, err = red:connect("127.0.0.1", 6379)
   if not ok then
      ngx.say("Failed to connect: ", err)
      return
   end

   local blacklist, err = red:keys("*:repsheet:ip:blacklisted")
   if not ok then
      ngx.say("Failed to get keys: ", err)
      return
   end

   local blacklist_with_reason = {}
   for k,v in pairs(blacklist) do
      local parts = split(v, "[^:]+")
      local reason, err = red:get(v)
      blacklist_with_reason[parts[1]] = reason
   end

   local response = cjson.encode({
         blacklist = blacklist_with_reason
   })

   ngx.say(response)

   return
end

blacklist()
