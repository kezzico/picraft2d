require 'generator'
require 'chunk'
local generator = Generator()

generator:thread_loop(function(params)
    print("generating chunk "..params.r.." "..params.c)
    chunk = Chunk:new()
    chunk:generate(params.seed, params.r, params.c)

    return chunk
end)
