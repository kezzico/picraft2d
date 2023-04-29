love.filesystem.load("TSerial.lua")()

function Terrain(seed, generator)
  return {
    state = {
      chunks = { },
      ghost_chunks  = { },
      chunk_buffers = { },
      render_chunk_borders = true,
      render_chunks = false,
      rMin = 0, rMax = 0, cMin = 0, cMax = 0
    },

    generate = function(self, view)
      -- insert chunks created by generator thread
      local chunk_str = generator.chunk_channel:pop()
      while chunk_str ~= nil do
        -- print("unpack chunk")
        local chunk = TSerial.unpack(chunk_str)

        local chunkrc = chunk.r..","..chunk.c

        self.state.chunks[chunkrc] = chunk

        chunk_str = generator.chunk_channel:pop()
      end

      local chunk_native_pixel_width = style.terrain.blocks_pixel_size * style.terrain.blocks_per_chunk

      local chunk_native_pixel_height = style.terrain.blocks_pixel_size * style.terrain.blocks_per_chunk

      local scale = view.zoom / style.terrain.native_zoom_scale

      local chunk_width = chunk_native_pixel_width * scale

      local chunk_height = chunk_native_pixel_height * scale

      local half_screen_height = global_state.screen_height / 2

      local half_screen_width = global_state.screen_width / 2

      local rect = {
        rMin = math.floor((view.y - half_screen_height) / chunk_height),
        rMax = math.floor((view.y + half_screen_height) / chunk_height),
        cMin = math.floor((view.x - half_screen_width) / chunk_width),
        cMax = math.floor((view.x + half_screen_width) / chunk_width)
      }

      -- release chunks off screen
      for chunkrc in pairs(self.state.chunks) do
        local chunk = self.state.chunks[chunkrc]

        if chunk.r + 2 < rect.rMin then
          local buffer = self.state.chunk_buffers[chunkrc]
          if buffer ~= nil then
            buffer:release()
          end

          self.state.chunks[chunkrc] = nil
          self.state.ghost_chunks[chunkrc] = nil
          self.state.chunk_buffers[chunkrc] = nil
        end

        if chunk.r - 2 > rect.rMax then
          local buffer = self.state.chunk_buffers[chunkrc]
          if buffer ~= nil then
            buffer:release()
          end

          self.state.chunks[chunkrc] = nil
          self.state.ghost_chunks[chunkrc] = nil
          self.state.chunk_buffers[chunkrc] = nil
        end

        if chunk.c + 2 < rect.cMin then
          local buffer = self.state.chunk_buffers[chunkrc]
          if buffer ~= nil then
            buffer:release()
          end

          self.state.chunks[chunkrc] = nil
          self.state.ghost_chunks[chunkrc] = nil
          self.state.chunk_buffers[chunkrc] = nil
        end

        if chunk.c - 2 > rect.cMax then
          local buffer = self.state.chunk_buffers[chunkrc]
          if buffer ~= nil then
            buffer:release()
          end

          self.state.chunks[chunkrc] = nil
          self.state.ghost_chunks[chunkrc] = nil
          self.state.chunk_buffers[chunkrc] = nil
        end
      end

      -- generate chunks in empty space
      ForEachRC(rect, function(r,c)
          local chunkrc = r..","..c

          local chunk = self.state.chunks[chunkrc]

          local ghost_chunk = self.state.ghost_chunks[chunkrc]

          if chunk == nil and ghost_chunk == nil then
            if r < self.state.rMin then self.state.rMin = r end
            if r > self.state.rMax then self.state.rMax = r end
            if c < self.state.cMin then self.state.cMin = c end
            if c > self.state.cMax then self.state.cMax = c end

            local command = { seed = seed, r = r, c = c }

            self.state.ghost_chunks[chunkrc] = { }

            generator.command_channel:push(TSerial.pack(command))
          end
      end)
    end,

    draw = function(self,view)
      local chunk_native_pixel_width = style.terrain.blocks_pixel_size * style.terrain.blocks_per_chunk

      local chunk_native_pixel_height = style.terrain.blocks_pixel_size * style.terrain.blocks_per_chunk

      local scale = view.zoom / style.terrain.native_zoom_scale

      local chunk_width = chunk_native_pixel_width * scale

      local chunk_height = chunk_native_pixel_height * scale

      local half_screen_height = global_state.screen_height / 2

      local half_screen_width = global_state.screen_width / 2

      local rect = {
        rMin = math.floor((view.y - half_screen_height) / chunk_height),
        rMax = math.floor((view.y + half_screen_height) / chunk_height),
        cMin = math.floor((view.x - half_screen_width) / chunk_width),
        cMax = math.floor((view.x + half_screen_width) / chunk_width)
      }

      ForEachRC(rect, function(r,c) 
        local chunkrc = r..","..c

        local chunk = self.state.chunks[chunkrc]

        local framebuffer = self.state.chunk_buffers[chunkrc]

        if chunk == nil then return end

        local chunk_x = chunk_width*chunk.c

        local chunk_y = chunk_height*chunk.r

        local render_x = chunk_x-view.x+half_screen_width

        local render_y = chunk_y-view.y+half_screen_height

        if framebuffer == nil then 
          framebuffer = love.graphics.newCanvas(chunk_pixel_width, chunk_pixel_height)
          self.state.chunk_buffers[chunkrc] = framebuffer

          love.graphics.setCanvas(framebuffer)
          framebuffer:setFilter("linear", "nearest")
          RenderChunk(chunk)
          love.graphics.setCanvas()
        end

        if self.state.render_chunks then
          love.graphics.draw(framebuffer, 
            render_x, render_y, 0, scale, scale)
        end

        -- render chunk debug info (borders, chunkrc)
        if self.state.render_chunk_borders then
          love.graphics.setFont(style.terrain.chunk.font)

          love.graphics.setColor(style.terrain.chunk.text_shadow_color)
          love.graphics.print(r..","..c,
            render_x + scale * 8, 
            render_y + scale * 8, 
            0, scale, scale)

          love.graphics.setColor(style.terrain.chunk.text_color)
          love.graphics.print(r..","..c,
            render_x - 0, 
            render_y - 0, 
            0, scale, scale)

          love.graphics.setColor(style.terrain.chunk.border_color)
          love.graphics.rectangle("line", 
            render_x, render_y,
            chunk_width, chunk_height)
          love.graphics.setColor(255,255,255,1)
        end

      end)
    end
  }

end

function RenderChunk(chunk)
  -- print("rendering chunk "..chunk.r..","..chunk.c)

  local rect = { 
    rMin = 1, 
    rMax = style.terrain.blocks_per_chunk,
    cMin = 1, 
    cMax = style.terrain.blocks_per_chunk
  }

  ForEachRC(rect, function(r,c) 
    local block = chunk.block[r][c]

    if block == AIR then
      return
    end

    local w = style.terrain.blocks_pixel_size
    local h = style.terrain.blocks_pixel_size
    local x = (c-1) * w
    local y = (r-1) * h

    love.graphics.setColor(255,255,255,1.0)
    love.graphics.rectangle("fill", x,y,w,h)
    love.graphics.setColor(255,255,255,1.0)
  end)
end

function ForEachRC(rect, action)
  for r = rect.rMin, rect.rMax do
    for c = rect.cMin, rect.cMax do
      action(r,c)
    end
  end

end
-- DRAW CHUNK

        -- love.graphics.draw(framebuffer, 
        --   (32*chunk.c-view.x)*view.zoom + global_state.screen_width/2, 
        --   (32*chunk.r-view.y)*view.zoom + global_state.screen_height/2, 
        --   0, view.zoom/16, view.zoom/16)

  -- for r = 1, 32 do
  --   for c = 1, 32 do
      -- if self.block[r][c] ~= AIR and self.block[r][c] ~= UNGENERATED then
      --   num = 1
      --   if joinsTo(self.block[r][c], self:getBlock(r-1, c), UP)    then num = num + 1 end
      --   if joinsTo(self.block[r][c], self:getBlock(r, c+1), RIGHT) then num = num + 2 end
      --   if joinsTo(self.block[r][c], self:getBlock(r+1, c), DOWN)  then num = num + 4 end
      --   if joinsTo(self.block[r][c], self:getBlock(r, c-1), LEFT)  then num = num + 8 end
      --   base = tileBase(self.block[r][c])
      --   if base ~= nil then love.graphics.draw(images[base][num], (c-1)*16, (r-1)*16) end
      --   love.graphics.draw(images[self.block[r][c]][num], (c-1)*16, (r-1)*16)
      -- end
  --   end
  -- end

            -- if self.framebuffer == nil or self.changed then self:render() end
            -- love.graphics.draw(self.framebuffer, (32*self.c-view.x)*view.zoom + love.graphics.getWidth()/2, (32*self.r-view.y)*view.zoom+love.graphics.getHeight()/2, 0, view.zoom/16, view.zoom/16)
            -- else
            -- for r = 1, 32 do
            --   for c = 1, 32 do
            --     if self.block[r][c] ~= AIR and self.block[r][c] ~= UNGENERATED then
            --       num = 1
            --       if joinsTo(self.block[r][c], self:getBlock(r-1, c), UP)    then num = num + 1 end
            --       if joinsTo(self.block[r][c], self:getBlock(r, c+1), RIGHT) then num = num + 2 end
            --       if joinsTo(self.block[r][c], self:getBlock(r+1, c), DOWN)  then num = num + 4 end
            --       if joinsTo(self.block[r][c], self:getBlock(r, c-1), LEFT)  then num = num + 8 end
            --       base = tileBase(self.block[r][c])
            --       if base ~= nil then love.graphics.draw(images[base][num], (c-1)*16, (r-1)*16) end
            --       love.graphics.draw(images[self.block[r][c]][num], (c-1)*16, (r-1)*16)
            --     end
            --   end
            -- end
            -- love.graphics.draw(self.framebuffer, (32*self.c-view.x)*view.zoom + love.graphics.getWidth()/2, (32*self.r-view.y)*view.zoom+love.graphics.getHeight()/2, 0, view.zoom/16, view.zoom/16)
            -- end

            -- love.graphics.setColor(0, 255, 1, 255)
            -- love.graphics.rectangle("fill", 
            --   (32*chunk.c-view.x)*view.zoom+love.graphics.getWidth()/2, 
            --   (32*chunk.r-view.y)*view.zoom+love.graphics.getHeight()/2, 
            --   view.zoom/16, view.zoom/16)







-- function Chunk:render()
--   if self.framebuffer == nil then
--     self.framebuffer = love.graphics.newCanvas(512, 512)
--     self.framebuffer:setFilter("linear", "nearest")
--   end
--   if not self.generated then return end
--   love.graphics.setCanvas(self.framebuffer)
--   love.graphics.clear()
--   love.graphics.setColor(255, 255, 255, 255)
--   local num, base
--   for r = 1, 32 do
--     for c = 1, 32 do
--       if self.block[r][c] ~= AIR and self.block[r][c] ~= UNGENERATED then
--         num = 1
--         if joinsTo(self.block[r][c], self:getBlock(r-1, c), UP)    then num = num + 1 end
--         if joinsTo(self.block[r][c], self:getBlock(r, c+1), RIGHT) then num = num + 2 end
--         if joinsTo(self.block[r][c], self:getBlock(r+1, c), DOWN)  then num = num + 4 end
--         if joinsTo(self.block[r][c], self:getBlock(r, c-1), LEFT)  then num = num + 8 end
--         base = tileBase(self.block[r][c])
--         if base ~= nil then love.graphics.draw(images[base][num], (c-1)*16, (r-1)*16) end
--         love.graphics.draw(images[self.block[r][c]][num], (c-1)*16, (r-1)*16)
--       end
--     end
--   end
--   love.graphics.setCanvas()
--   self.changed = false
-- end


-- Terrain = {}

-- function Terrain:new(seed)
--   local o = {}
--   setmetatable(o, self)
--   self.__index = self

--   o.seed = seed or os.time()
--   o.chunk = {}
--   o.generationQueue = {}
--   o.rMin = -3
--   o.rMax = 0
--   o.cMin = -2
--   o.cMax = 1
--   o.entities = {}

--   return o
-- end

-- function Terrain:addChunk(chunk, r, c)
  -- expand rc bounds if needed
--   if r < self.rMin then self.rMin = r end
--   if r > self.rMax then self.rMax = r end
--   if c < self.cMin then self.cMin = c end
--   if c > self.cMax then self.cMax = c end

--   -- new row
--   if self.chunk[r] == nil then self.chunk[r] = {} end

--   -- keep reference
--   self.chunk[r][c] = chunk

--   -- circular references
--   self.chunk[r][c].terrain = self
--   self.chunk[r][c].r = r
--   self.chunk[r][c].c = c
-- end

-- function Terrain:getChunk(r, c)
--   assert(self.chunk[r] ~= nil)
--   assert(self.chunk[r][c] ~= nil)
--   return self.chunk[r][c]
-- end

-- function Terrain:hasChunk(r, c)
--   return self.chunk[r] ~= nil and self.chunk[r][c] ~= nil
-- end

-- function Terrain:setBlock(r, c, block)
--   local relR = (r - 1) % 32 + 1
--   local relC = (c - 1) % 32 + 1
--   local chunkR = (r - relR) / 32
--   local chunkC = (c - relC) / 32
--   if self:hasChunk(chunkR, chunkC) then
--     self:getChunk(chunkR, chunkC):setBlock(relR, relC, block)
--   end
-- end

-- function Terrain:getBlock(r, c)
--   local relR = (r - 1) % 32 + 1
--   local relC = (c - 1) % 32 + 1
--   local chunkR = (r - relR) / 32
--   local chunkC = (c - relC) / 32
--   if self:hasChunk(chunkR, chunkC) then
--     return self:getChunk(chunkR, chunkC):getBlock(relR, relC)
--   else
--     return UNGENERATED
--   end
-- end

-- function Terrain:addEntity(id, y, x)
--   if id == nil then return end
--   local entity = Entity:new(id, y, x)
--   table.insert(self.entities, entity)
-- end

-- function Terrain:getSeed()
--   return self.seed
-- end

-- function Terrain:calculateSunLight()
--   for c = self.cMin, self.cMax do
--     local topFound = false
--     local top
--     for r = self.rMin, self.rMax do
--       if not topFound and self:hasChunk(r, c) then
--         topFound = true
--         top = r
--       end
--     end
--     if top >= 0 then break end

--     for c2 = 1, 32 do
--       local carry = false
--       if self:getChunk(r, c):getBlock(1, c2) == AIR then carry = true end
--       for r = top, self.rMax do
--         if carry and not self:hasChunk(r, c) and r >= 0 then break
--         elseif carry then self:getChunk(r, c):setSunLight(1, c2, 16)
--         else break end
--         if self:hasChunk(r, c) then
--           for r2 = 1, 31 do
--             if self:getChunk(r, c).sunLight[r2][c2] == 16 and self:getChunk(r, c):getBlock(1, c2) == AIR then
--               self:getChunk(r, c):setSunLight(r2+1, c2, 16)
--             else
--               break
--             end
--           end
--           if self:getChunk(r, c).sunLight[32][c2] == 16 and self:getChunk(r, c):getBlock(32, c2) == AIR then carry = true
--           else carry = false end
--         end
--       end
--     end
--   end
-- end

-- function Terrain:generate(r, c)
--   if self:hasChunk(r, c) then return
--   else
--     table.insert(self.generationQueue, {r = r, c = c})
--     self:addChunk(Chunk:new(), r, c)
--   end
-- end

-- function Terrain:checkGenerator()
--   local chunk_channel = love.thread.getChannel('generator_chunk')
--   local command_channel = love.thread.getChannel('generator_command')

--   local chunk_str = chunk_channel:pop()
--   while chunk_str ~= nil do
--     chunkNew = TSerial.unpack(chunk_str)
--     chunk = self:getChunk(chunkNew.r, chunkNew.c)
--     chunk.block = chunkNew.block
--     chunk.generated = true
--     chunk.hasDirt = chunkNew.hasDirt
--     chunk:renderPerlin()
--     for r = 0, 1 do
--       for c = -1, 1 do
--         if self:hasChunk(chunk.r + r, chunk.c + c) then
--           self:getChunk(chunk.r + r, chunk.c + c):generateTrees()
--         end
--       end
--     end
--     for r = -1, 1 do
--       for c = -1, 1 do
--         if self:hasChunk(chunk.r + r, chunk.c + c) then
--           self:getChunk(chunk.r + r, chunk.c + c).changed = true
--         end
--       end
--     end

--     chunk_str = chunk_channel:pop()
--   end

--   local chunkRC = table.remove(self.generationQueue, 1)
--   if chunkRC ~= nil then
--     local command = {seed = self:getSeed(), r = chunkRC.r, c = chunkRC.c}
--     command_channel:push(TSerial.pack(command))
--   end
--   --end
-- end

-- function Terrain:draw(view)
--   local skyPos = love.graphics.getHeight()/2 - (view.y - 16) * view.zoom / 2
--   if skyPos > 0 then
--     love.graphics.setColor(161, 235, 255, 255)
--     love.graphics.rectangle("fill", -1, -1, love.graphics.getWidth()+2, skyPos)
--   end
--   if skyPos < love.graphics.getHeight() then
--     love.graphics.setColor(0, 26, 34, 255)
--     love.graphics.rectangle("fill", -1, skyPos, love.graphics.getWidth()+2, love.graphics.getHeight() - skyPos)
--   end
--   love.graphics.setColor(255, 255, 255, 255)
--   love.graphics.draw(sky, -1, skyPos, 0, (love.graphics.getWidth()+2)/sky:getWidth(), view.zoom/8, 0, 256)

  -- local minR = math.max(self.rMin, math.floor((view.y - view.zoom * (love.graphics.getHeight() / 2)) / 32))
  -- local maxR = math.min(self.rMax, math.floor((view.y + view.zoom * (love.graphics.getHeight() / 2)) / 32))
  -- local minC = math.max(self.cMin, math.floor((view.x - view.zoom * (love.graphics.getWidth()  / 2)) / 32))
  -- local maxC = math.min(self.cMax, math.floor((view.x + view.zoom * (love.graphics.getWidth()  / 2)) / 32))
  -- love.graphics.setColor(255, 255, 255, 255)
  -- for r = minR, maxR do
  --   for c = minC, maxC do
  --     if self:hasChunk(r, c) then
  --       self:getChunk(r, c):draw(view)
  --     end
  --   end
  -- end
--   for i = 1, #self.entities do
--     self.entities[i]:draw(view)
--   end
-- end



        -- chunk = self:getChunk(chunkNew.r, chunkNew.c)
        -- chunk.block = chunkNew.block
        -- chunk.generated = true
        -- chunk.hasDirt = chunkNew.hasDirt
        -- chunk:renderPerlin()
        -- for r = 0, 1 do
        --   for c = -1, 1 do
        --     if self:hasChunk(chunk.r + r, chunk.c + c) then
        --       self:getChunk(chunk.r + r, chunk.c + c):generateTrees()
        --     end
        --   end
        -- end
        -- for r = -1, 1 do
        --   for c = -1, 1 do
        --     if self:hasChunk(chunk.r + r, chunk.c + c) then
        --       self:getChunk(chunk.r + r, chunk.c + c).changed = true
        --     end
        --   end
        -- end


-- function Rect(rMin, rMax, cMin, cMax)
--   return {
--     rMin = rMin or 0,
--     rMax = rMax or 0,
--     cMin = cMin or 0,
--     cMax = cMax or 0
--   }
-- end
