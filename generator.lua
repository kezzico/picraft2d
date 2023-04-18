require("love.timer")
require("love.filesystem")
love.filesystem.load("TSerial.lua")()
love.filesystem.load("common.lua")()
love.filesystem.load("chunk.lua")()

function Generator()
  return {
    thread = nil,

    run = true,

    chunk_channel = love.thread.getChannel('generator_chunk'),

    command_channel = love.thread.getChannel('generator_command'),

    start = function(self) 
      self.command_channel:clear()
      
      if self.thread == nil then
        self.thread = love.thread.newThread("generator_thread.lua")
        print("....")
        
        self.thread:start()
      end
    end,

    thread_loop = function(self)
      print("terrain generator started")

      while self.run == true do 
        commandMsg = self.command_channel:demand()
        if commandMsg == "quit" then self.run = false
        else
          local command = TSerial.unpack(commandMsg)

          chunk = Chunk:new()
          chunk:generate(command.seed, command.r, command.c)

          self.chunk_channel:push(TSerial.pack(chunk))
          print("generated chunk at " .. command.r .. ", " .. command.c)
        end
      end
    end
  }
end

terrain_generator = Generator()
