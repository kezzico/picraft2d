function Generator(seed, threadcode)
  return {
    chunk_queue = { },

    chunk_channel = love.thread.getChannel('generator_chunk_'),

    command_channel = love.thread.getChannel('generator_command_'),

    start = function(self)
      local thread = love.thread.newThread(threadcode)

      thread:start(chunk_channel, command_channel)
    end,

    stop = function(self)
      self.chunk_channel:clear()

      self.command_channel:clear()

      self.command_channel:push("quit")

      self.chunk_queue = { }
    end,

    push = function(self, r, c)
      local chunkrc = r..","..c

      local ghost_chunk = self.chunk_queue[chunkrc]

      if ghost_chunk ~= nil then
        return
      end

      self.chunk_queue[chunkrc] = { }

      local command = { seed = seed, r = r, c = c }

      self.command_channel:push(command)

    end,

    pull = function(self, chunktable)
      local chunk = self.chunk_channel:pop()
      while chunk ~= nil do
        -- print("pulled chunk"..table_to_string(chunkdata))
        local chunkrc = chunk.r..","..chunk.c
        -- print("chunkrc="..chunkrc)
        chunktable[chunkrc] = chunk
        self.chunk_queue[chunkrc] = nil

        chunk = self.chunk_channel:pop()
      end
    end,

    thread_loop = function(self, chunk_generator)
      print("terrain generator started")

      local msg = self.command_channel:demand()

      while msg ~= "quit" do        
        local params = msg

        local chunk = chunk_generator(params)

        self.chunk_channel:push(chunk)

        msg = self.command_channel:demand()
      end
    end
  }
end
