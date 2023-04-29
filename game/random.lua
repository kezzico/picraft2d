function random(seed, str)
  -- print(str)
  local hash = love.data.hash( "sha256", seed..str )

  local hex = love.data.encode("string", "hex", hash)

  local number = tonumber(hex:sub(1,8), 16)
  -- print(number)
  return number / 4294967295 -- 2^32
end
