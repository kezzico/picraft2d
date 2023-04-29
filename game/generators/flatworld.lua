require 'generator'
require 'chunk'
local generator = Generator()

generator:thread_loop(function(params)
    chunk = Chunk:new()

    chunk.r = params.r
    chunk.c = params.c
    -- for r = 1, 32 do
    --   chunk.block[r] = {}
    --   chunk.perlin[r] = {}
    --   for c = 1, 32 do
    --     chunk.block[r][c] = STONE
    --     chunk.perlin[r][c] = 0
    --   end
	  -- chunk.perlin = {}
	  -- chunk.generated = true
	  -- chunk.changed = true
	  -- chunk.r = params.r
	  -- chunk.c = params.c

    -- end


    return chunk
end)
