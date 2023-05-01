require 'TSerial'
require 'blocks'

function Terrain(generator)
  local chunkfont = cache.font(style.terrain.chunk.fontname)

  local function ForEachRC(rect, action)
    for r = rect.rMin, rect.rMax do
      for c = rect.cMin, rect.cMax do
        action(r,c)
      end
    end
  end

  local function viewToRect(view)
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

      return rect
  end

  local function RenderChunk(chunk)
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

      if block == 0 then
        return
      end

      local w = style.terrain.blocks_pixel_size
      local h = style.terrain.blocks_pixel_size
      local x = (c-1) * w
      local y = (r-1) * h

      local block_type = Blocks[block]

      if block_type == nil then
        return
      end

      local tname = block_type.texture
      local texture = cache.image(tname)
      local sx = w / texture:getWidth()
      local sy = h / texture:getHeight()

      love.graphics.setColor(1,1,1,1.0)
      love.graphics.draw(texture,x,y,0,sx,sy)
      -- love.graphics.setColor(1,1,1,0.5)
      -- love.graphics.rectangle("fill", x,y,w,h)
      love.graphics.setColor(255,255,255,1.0)
    end)
  end


  return {
    state = {
      chunks = { },
      -- ghost_chunks  = { },
      chunk_buffers = { },

      render_chunk_borders = false,
      render_chunks = true,
      rMin = 0, rMax = 0, cMin = 0, cMax = 0
    },

    clean = function(self, view)
      local rect = viewToRect(view)
      -- release chunks off screen
      for chunkrc in pairs(self.state.chunks) do
        local chunk = self.state.chunks[chunkrc]

        if
          chunk.r + 2 < rect.rMin or
          chunk.r - 2 > rect.rMax or
          chunk.c + 2 < rect.cMin or 
          chunk.c - 2 > rect.cMax then

          print("release chunk "..chunk.r..' '..chunk.c)
          local buffer = self.state.chunk_buffers[chunkrc]

          if buffer ~= nil then
            buffer:release()
          end

          self.state.chunks[chunkrc] = nil
          self.state.chunk_buffers[chunkrc] = nil
        end

      end
    end,

    generate = function(self, view)
      -- pull chunks created by generator thread
      generator:pull(self.state.chunks)

      local rect = viewToRect(view)
      -- push chunks to be generated to thread
      ForEachRC(rect, function(r,c)
          local chunkrc = r..","..c

          local chunk = self.state.chunks[chunkrc]

          if chunk == nil then
            generator:push(r, c)
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
          framebuffer = love.graphics.newCanvas(chunk_native_pixel_width, chunk_native_pixel_height)
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

