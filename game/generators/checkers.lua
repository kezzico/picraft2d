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

      x = i,

      y = j
    }
end

local function forEachBlock(fn)
  -- 1 block padding to include block in adjacent chunk
  for i=-1, chunk_height+1 do
    for j=-1, chunk_width+1 do
        fn(i, j)
    end
  end
end

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


    if (i + j) % 4 == 0 then
    front_block = Block(i,j,biome.hardblock)
    end

    back_block = nil

    chunk.front[blockid] = front_block

    chunk.back[blockid] = back_block
  end)

  return chunk
end)

