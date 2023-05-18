require 'table_to_string'
require 'generator'
require 'perlin'
require 'style'
require 'random'
require 'wave'
require 'chunk'

Generator():thread_loop(function(params)
  local seed = params.seed
  local chunk = Chunk(params)
  local biome = biomes.overworld

  chunk.front = generate_blocks(params, function(x,y)
    if y > 15 and y < 18 then
      return biome.groundy
    end
    -- if params.r == 5 and j > 2 then
    --   print(x..' '..y)
      -- return Block(i,j,biome.groundy)
    -- elseif params.r > 5 then
    --   return Block(i,j,biome.groundy)
    -- end

    return nil
  end)

  chunk.back = generate_blocks(params, function(i,j,x,y)
    return nil
  end)

  return chunk
end)

