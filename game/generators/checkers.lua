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

  chunk.front = generate_blocks(params, function(x,y)
    local biome = biomes.overworld

    if (x + y) % 4 == 0 then
      return biome.hardblock
    end

    return nil
  end)

  chunk.back = generate_blocks(params, function(x,y)
    return nil
  end)

  return chunk
end)

