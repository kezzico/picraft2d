function table_to_string(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. table_to_string(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

function random(seed, str)
  local hash = love.data.hash( "sha256", seed..str )

  local hex = love.data.encode("string", "hex", hash)

  local number = tonumber(hex:sub(1,8), 16)

  return number
end

local start = os.time()
for i=1,1024*1024 do
   local data = {
     r = i,

     c = -6,

     layer = 5,

     block = 3
   }

  -- local number = random(12345, table_to_string(data)) % 256
   local number = random(12345, data.r..","..data.c..","..data.layer..","..data.block) % 256
  -- print(number)
end
print(os.time() - start)
love.event.quit()

-- function get_random(index)
--   local seed = "your_seed_string_here"
--   local sha_result = sha2.sha256(seed .. tostring(index))
--   return tonumber(sha_result, 16) -- convert hexadecimal string to integer
-- end
