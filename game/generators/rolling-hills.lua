require 'table_to_string'
require 'generator'
require 'perlin'
require 'style'
require 'random'
require 'wave'

local chunk_width = style.terrain.blocks_per_chunk
local chunk_height = style.terrain.blocks_per_chunk
local block_width = style.terrain.blocks_pixel_size
local block_height = style.terrain.blocks_pixel_size

function Chunk(p)
  return {
    r = p.r or 0,

    c = p.c or 0,

    front = { },

    back = { }
  }
end

function Block(i, j, type) 
  return { 
      type = type,
      x = i * block_width,
      y = j * block_height
    }
end

local function forEachBlock(fn)
  for i=1, chunk_height do
    for j=1, chunk_width do
        fn(i-1, j-1)
    end
  end
end

local blocks = {

}

Generator():thread_loop(function(params)
  local seed = params.seed
  local chunk = Chunk(params)

  forEachBlock(function(i,j) 
    local blockid = i..','..j
    local y = params.r*chunk_height+i
    local x = params.c*chunk_width+j

    local back_block = nil

    local front_block = nil

    local biome = biomes.overworld

    -- 40 to 80
    if y < wave(seed, x, 22, 66) - 44 then
      return
    end


    -- underworld biome
    if y > wave(seed, x, 4, 88) then
      biome = biomes.underworld

      if perlin(seed, x, y, 88) < 0.0 then
        if perlin(seed, x, y, 3) > -0.2 then
          front_block = Block(i,j,biome.hardblock)
        else
          front_block = Block(i,j,biome.groundy)
        end
      else
        if perlin(seed, x, y, 2) < 0.0 then
          back_block = Block(i,j,biome.background[1])
        else
          back_block = Block(i,j,biome.bricks)
        end

      end
    elseif y > wave(seed,x,44,55) - 66 then
      biome = biomes.overworld
      front_block = Block(i,j,biome.groundy)


    end

    -- local diversity_front = perlin(seed, x, y, 3)

    -- local diversity_back = perlin(seed, x, y, 2)

    chunk.front[blockid] = front_block

    chunk.back[blockid] = back_block
  end)

  return chunk
end)

  -- local block_width = style.terrain.blocks_per_chunk
  -- local block_height = style.terrain.blocks_per_chunk

  -- chunk = { r = params.r, c = params.c, blocks = { } }

  -- for i=1, block_height do
  --   for j=1, block_width do
  --     local y = params.r*block_height+i
  --     local x = params.c*block_width+j

  --     if y > wave(params.seed, x, 4, 88) then
  --       -- local p = perlin(params.seed, x, y)
  --       -- if p < -0.45 then
  --       --   -- ore
  --       --   chunk.block[i][j] = 3
  --       -- elseif p < 0.0 then
  --       --   -- cave
  --       --   chunk.block[i][j] = 2
  --       -- else
  --       --   chunk.block[i][j] = 1
  --       -- end
  --     end
  --   end
  -- end

  -- return chunk
