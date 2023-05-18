require 'table_to_string'
require 'generator'
require 'perlin'
require 'style'
require 'random'
require 'wave'

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

    -- sky biome
    if y < wave(seed, x, 22, 66) - 44 then
      return nil
    end

    -- underworld biome
    if y > wave(seed, x, 4, 88) then
      biome = biomes.underworld

      if perlin(seed, x, y, 88) < 0.0 then
        if perlin(seed, x, y, 3) > -0.2 then
          return biome.hardblock
        else
          return biome.groundy
        end
      end
    -- overworld biome
    elseif y > wave(seed,x,44,55) - 66 then
      biome = biomes.overworld
      return i,j,biome.groundy
    end

    return nil
  end)

  chunk.back = generate_blocks(params, function(x,y)
    local biome = biomes.overworld

    -- underworld biome
    if y > wave(seed, x, 4, 88) then
      biome = biomes.underworld

      if perlin(seed, x, y, 88) < 0.0 then
      else
        if perlin(seed, x, y, 2) < 0.0 then
          return i,j,biome.background[1]
        else
          return i,j,biome.bricks
        end
      end
    end

    return nil
  end)

  return chunk
end)

