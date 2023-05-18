
function Terrain(generator)
  local chunkfont = cache.font(style.terrain.chunk.fontname)

  local function ForEachRC(rect, action)
    for r = rect.rMin, rect.rMax do
      for c = rect.cMin, rect.cMax do
        action(r,c)
      end
    end
  end

  -- test me
  local function viewToRect(view)
      local chunk_native_pixel_width = style.terrain.blocks_pixel_size * style.terrain.blocks_per_chunk

      local chunk_native_pixel_height = style.terrain.blocks_pixel_size * style.terrain.blocks_per_chunk

      local scale = view.zoom / style.terrain.native_zoom_scale

      local chunk_width = chunk_native_pixel_width * scale

      local chunk_height = chunk_native_pixel_height * scale

      local half_screen_height = view.screen_height / 2

      local half_screen_width = view.screen_width / 2

      local rect = {
        rMin = math.floor((view.y - half_screen_height) / chunk_height),
        rMax = math.floor((view.y + half_screen_height) / chunk_height),
        cMin = math.floor((view.x - half_screen_width) / chunk_width),
        cMax = math.floor((view.x + half_screen_width) / chunk_width)
      }

      return rect
  end

  local function RenderChunk(blocks)
  -- print("rendering chunk "..chunk.r..","..chunk.c)
    local chunk_width = style.terrain.blocks_per_chunk
    local chunk_height = style.terrain.blocks_per_chunk

    local w = style.terrain.blocks_pixel_size

    local h = style.terrain.blocks_pixel_size

    forEachPair(blocks, function(block)
      if block.i < 0 or block.i >= chunk_width then return end
      if block.j < 0 or block.j >= chunk_height then return end

      local x = block.i * style.terrain.blocks_pixel_size 

      local y = block.j * style.terrain.blocks_pixel_size

      local t = block.type

      if t ~= nil then
        local texture = cache.image(t.texture)
        local sx = w / texture:getWidth()
        local sy = h / texture:getHeight()

        love.graphics.setColor(1,1,1,1.0)
        love.graphics.draw(texture,x,y,0,sx,sy)
      else
        print("unknown block type ".. table_to_string(t))
      end
    end)

  end

  return {
    state = {
      chunks = { },
      chunk_front_buffers = { },
      chunk_back_buffers = { },

      render_collision_barriers = true,
      render_chunk_borders = false,
      render_chunks = true,
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

          -- print("release chunk "..chunk.r..' '..chunk.c)
          local front_buffer = self.state.chunk_front_buffers[chunkrc]

          if front_buffer ~= nil then
            front_buffer:release()
          end

          local back_buffer = self.state.chunk_back_buffers[chunkrc]

          if back_buffer ~= nil then
            back_buffer:release()
          end

          self.state.chunks[chunkrc] = nil
          self.state.chunk_front_buffers[chunkrc] = nil
          self.state.chunk_back_buffers[chunkrc] = nil
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

      local half_screen_height = view.screen_height / 2

      local half_screen_width = view.screen_width / 2

      local rect = {
        rMin = math.floor((view.y - half_screen_height) / chunk_height),
        rMax = math.floor((view.y + half_screen_height) / chunk_height),
        cMin = math.floor((view.x - half_screen_width) / chunk_width),
        cMax = math.floor((view.x + half_screen_width) / chunk_width)
      }

      ForEachRC(rect, function(r,c) 
        local chunkrc = r..","..c

        local chunk = self.state.chunks[chunkrc]

        local framebuffer_front = self.state.chunk_front_buffers[chunkrc]
        local framebuffer_back = self.state.chunk_back_buffers[chunkrc]

        if chunk == nil then return end

        local chunk_x = chunk_width*chunk.c

        local chunk_y = chunk_height*chunk.r

        local render_x = chunk_x-view.x+half_screen_width

        local render_y = chunk_y-view.y+half_screen_height

        if framebuffer_front == nil then 
          framebuffer_front = love.graphics.newCanvas(chunk_native_pixel_width, chunk_native_pixel_height)
          self.state.chunk_front_buffers[chunkrc] = framebuffer_front

          love.graphics.setCanvas(framebuffer_front)
          framebuffer_front:setFilter("linear", "nearest")
          RenderChunk(chunk.front)
          love.graphics.setCanvas()
        end

        if framebuffer_back == nil then 
          framebuffer_back = love.graphics.newCanvas(chunk_native_pixel_width, chunk_native_pixel_height)
          self.state.chunk_back_buffers[chunkrc] = framebuffer_back

          love.graphics.setCanvas(framebuffer_back)
          framebuffer_back:setFilter("linear", "nearest")
          RenderChunk(chunk.back)
          love.graphics.setCanvas()
        end

        if self.state.render_chunks then
          love.graphics.setColor(0.5,0.5,0.5,1.0)
          love.graphics.draw(framebuffer_back, 
            render_x, render_y, 0, scale, scale)
          love.graphics.setColor(1.0,1.0,1.0,1.0)

          love.graphics.draw(framebuffer_front, 
            render_x, render_y, 0, scale, scale)
          love.graphics.setColor(1.0,1.0,1.0,1.0)
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

        if self.state.render_collision_barriers then
          local barriers = collision_barriers(chunk.front)

          love.graphics.setColor(0,1,0,1)

          for i=1,#barriers do
            -- print(table_to_string(barriers[i]))
            love.graphics.line(
              barriers[i][1][1] * scale + render_x,
              barriers[i][1][2] * scale + render_y,
              barriers[i][2][1] * scale + render_x,
              barriers[i][2][2] * scale + render_y)
          end

          love.graphics.setColor(1,1,1,1)
      end

      end)
    end
  }
end

