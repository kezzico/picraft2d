local bb = 88

-- Interpolation function
local function lerp(a, b, t)
  return a + t * (b - a)
end

-- Generate random gradient vectors
local function random_gradient(seed, x, y)
  local r = random(seed, x..","..y)
  -- print(r)
  local angle = r * 2 * math.pi
  -- print(angle)
  return {
    math.cos(angle), 
    math.sin(angle)
  }

end

local function dotgradient(seed, ix, iy, x, y)
  -- local b = style.terrain.blocks_per_chunk

  local g = random_gradient(seed, ix, iy)

  local dx = (x - ix) / bb

  local dy = (y - iy) / bb

  return dx * g[1] + dy * g[2]

end

-- Calculate Perlin noise at a given point
function perlin(seed, x, y)
  -- Determine the grid cell coordinates
  local b = style.terrain.blocks_per_chunk
  local x0 = math.floor(x / bb) * bb
  local x1 = x0 + bb
  local y0 = math.floor(y / bb) * bb
  local y1 = y0 + bb

  -- Determine the distance between the point and the grid cell
  local dx = (x - x0) / bb
  local dy = (y - y0) / bb

  local n0 = dotgradient(seed, x0, y0, x, y)
  local n1 = dotgradient(seed, x1, y0, x, y)
  local ix0 = lerp(n0, n1, dx)

  local n2 = dotgradient(seed, x0, y1, x, y)
  local n3 = dotgradient(seed, x1, y1, x, y)
  local ix1 = lerp(n2, n3, dx)
  local noise = lerp(ix0, ix1, dy)

  return noise
end