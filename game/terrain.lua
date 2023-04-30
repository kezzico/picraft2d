require 'TSerial'

function Terrain(seed, generator)
  local chunkfont = cache.font(style.terrain.chunk.fontname)

  return {
    state = {
      chunks = { },
      ghost_chunks  = { },
      chunk_buffers = { },
      render_chunk_borders = false,
      render_chunks = true,
      rMin = 0, rMax = 0, cMin = 0, cMax = 0
    },

    generate = function(self, view)
      -- insert chunks created by generator thread
      local chunk_str = generator.chunk_channel:pop()
      while chunk_str ~= nil do
        -- print("unpack chunk"..chunk_str)
        local chunk = TSerial.unpack(chunk_str)
        -- print("chunk result"..table_to_string(chunk))
        local chunkrc = chunk.r..","..chunk.c
        -- print("chunkrc="..chunkrc)
        self.state.chunks[chunkrc] = chunk
        self.state.ghost_chunks[chunkrc] = nil

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
          love.graphics.setFont(chunkfont)

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
    -- print("👀"..#chunk.block.." "..r..","..c)
    local block = chunk.block[r][c]

    -- if block == AIR then
    --   return
    -- end

    local w = style.terrain.blocks_pixel_size
    local h = style.terrain.blocks_pixel_size
    local x = (c-1) * w
    local y = (r-1) * h

    -- if (chunk.c % 2) == 1 and (chunk.r % 2) == 0 then love.graphics.setColor(block,0,0,1.0)
    -- elseif (chunk.c % 2) == 0 and (chunk.r % 2) == 1 then love.graphics.setColor(block,0,0,1.0)
    -- else love.graphics.setColor(0,block,0,1.0) end
    love.graphics.setColor(block,0,0,1.0)
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
