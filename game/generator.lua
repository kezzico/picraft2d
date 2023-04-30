require 'TSerial'

function Generator(generator)
  return {
    thread = nil,

    chunk_channel = love.thread.getChannel('generator_chunk'),

    command_channel = love.thread.getChannel('generator_command'),

    start = function(self) 
      self.command_channel:push("quit")

      self.chunk_channel:clear()

      self.command_channel:clear()
      
      if self.thread == nil then
        self.thread = love.thread.newThread(generator)
        
        self.thread:start(chunk_channel, command_channel)
      end
    end,

    stop = function(self)
      self.command_channel:push("quit")      
    end,

    thread_loop = function(self, chunk_generator)
      print("terrain generator started")

      local msg = self.command_channel:demand()

      while msg ~= "quit" do
        local params = TSerial.unpack(msg)

        local chunk = chunk_generator(params)

        self.chunk_channel:push(TSerial.pack(chunk))

        msg = self.command_channel:demand()
      end
    end
  }
end
