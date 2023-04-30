require 'generator'
require 'perlin'
require 'table_to_string'
require 'style'
require 'random'
require 'wave'

local generator = Generator()

generator:thread_loop(function(params)
  local block_width = style.terrain.blocks_per_chunk
  local block_height = style.terrain.blocks_per_chunk

  chunk = { r = params.r, c = params.c, block = { } }

  for i=1, block_height do
    chunk.block[i] = { }
    for j=1, block_width do
      local y = params.r*block_height+i
      local x = params.c*block_width+j

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

