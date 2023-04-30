require 'generator'
require 'perlin'
require 'table_to_string'
require 'style'
require 'random'

local generator = Generator()

local function lerp(a, b, t)
  return a + t * (b - a)
end

local function smoothstep(x)
  return 3 * x^2 - 2 * x^3
end

local function wave(seed, x, freq, amp)
  local block_width = style.terrain.blocks_per_chunk
  -- local p0 = math.floor(params.c / freq) * freq
  local c  = x / block_width
  local p0 = math.floor(c / freq) * freq
  local p1 = p0 + freq
  local px = ((c) - p0) / freq

  local h0 = random(seed, p0..'') * amp
  local h1 = random(seed, p1..'') * amp

  local wave = lerp(h0, h1, px)

  return wave
end

generator:thread_loop(function(params)
  local block_width = style.terrain.blocks_per_chunk
  local block_height = style.terrain.blocks_per_chunk

  chunk = { r = params.r, c = params.c, block = { } }

  for i=1, block_height do
    chunk.block[i] = { }
    for j=1, block_width do
      local y = params.r*block_height+i
      local x = params.c*block_width+j

      -- waves
      -- local b = 4
      -- local p0 = math.floor(params.c / b) * b
      -- local p1 = p0 + b
      -- local px = ((x / block_width) - p0) / b

      -- local h0 = random(params.seed, p0..'') * 88
      -- local h1 = random(params.seed, p1..'') * 88

      -- local wave = lerp(h0, h1, px)
      --

      if y > wave(params.seed, x, 4, 88) then
        local p = perlin(params.seed, x, y)
        if p < -0.3 then
          -- ore
          chunk.block[i][j] = 1.0
        elseif p < 0.0 then
          -- cave
          chunk.block[i][j] = 0.11
        else
          chunk.block[i][j] = 1.0
        end
      else
        chunk.block[i][j] = 0.0
      end
    end
  end

  return chunk
end)

