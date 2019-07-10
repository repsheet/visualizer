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
   if not blacklist then
      ngx.say("Failed to get keys: ", err)
      return
   end

   for k,v in pairs(blacklist) do
      local parts = split(v, "[^:]+")
      blacklist[k] = parts[1]
   end

   local response = cjson.encode({
         blacklist = blacklist
   })

   ngx.say(response)

   return
end

blacklist()
