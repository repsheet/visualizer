local redis = require 'resty.redis'
local cjson = require 'cjson'

function split(str, sep)
   local words = {}
   for w in string.gmatch(str, sep) do
      table.insert(words, w)
   end
   return words
end

function Set (list)
   local set = {}
   for _, l in ipairs(list) do set[l] = true end
   return set
end

function is_valid_list_type(list_type)
   local valid_list_types = Set { "blacklist", "whitelist", "mark" }

   if valid_list_types[list_type] then
      return true
   else
      return false
   end
end

function generate_error_message(message)
   local response = cjson.encode({
         error = message
   })

   return response
end

function populate_reasons(red, results)
   local list_with_reason = {}
   for k,v in pairs(results) do
      local parts = split(v, "[^:]+")
      local reason, err = red:get(v)
      if not reason then
         ngx.say(generate_error_message("Failed to get reason: "..err))
         return
      end
      list_with_reason[parts[1]] = reason
   end

   return list_with_reason
end

function list()
   local red = redis:new()
   local ok, err = red:connect("127.0.0.1", 6379)
   if not ok then
      ngx.say(generate_error_message("Failed to connect: "..err))
      return
   end

   local list_type = ngx.var.arg_type
   if not is_valid_list_type(list_type) then
      ngx.say(generate_error_message("Invalid list type specified"))
      return
   end

   local list, err = red:keys("*:repsheet:ip:"..list_type.."ed")
   if not list then
      ngx.say(generate_error_message("Failed to get keys: "..err))
      return
   end

   if not ngx.var.arg_include_reason then
      for k,v in pairs(list) do
         local parts = split(v, "[^:]+")
         list[k] = parts[1]
      end
   else
      local list_with_reason = {}
      for k,v in pairs(list) do
         local parts = split(v, "[^:]+")
         local reason, err = red:get(v)
         if not reason then
            ngx.say(generate_error_message("Failed to get reason: "..err))
            return
         end
         list_with_reason[parts[1]] = reason
      end

      list = list_with_reason
   end

   local response = cjson.encode({
         list = list
   })

   ngx.say(response)

   return
end

list()
