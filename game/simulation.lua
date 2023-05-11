function Simulation(seed)
	local entity_buffers = { }

	function forEachEntity(entities, callback)
		for i=1, #entities do
			callback(entities[i])
		end
	end

	function positionToChunkRC(position)	
		local x = position.x
		local y = position.y

		local chunk_size = style.terrain.blocks_per_chunk * style.terrain.blocks_pixel_size

		local c = math.floor(x / chunk_size)

		local r = math.floor(y / chunk_size)

		local chunkrc = r..","..c

		-- print(math.floor(x)..','..math.floor(y)..'='..chunkrc)

		return chunkrc
	end

	return { 
		state = {
			entities = { }
		},

		clean = function(self, chunks)
			local entities = self.state.entities

			forEachEntity(self.state.entities, function(entity)
				local eid = entity.eid

				local buffer = entity_buffers[eid]

				-- local chunkrc = positionToChunkRC(entity.state.position)

				-- local chunk = chunks[chunkrc]

				-- if chunk == nil and buffer ~= nil then
				if buffer ~= nil then
					buffer:release()

					entity_buffers[eid] = nil
				end
			end)
		end,

		update = function(self, dt, chunks)
			local entities = self.state.entities

			local gravity = Vector.new(0,999.0)

			local inertia = -0.0165 * 64

			forEachEntity(self.state.entities, function(entity)
				local chunkrc = positionToChunkRC(entity.state.position)

				local chunk = chunks[chunkrc]

				if chunk == nil then
					-- print("out of bounds")
					return
				end

				chunk.highlight = true
				local v0 = entity.state.velocity
				local v1 = v0 + (v0 * inertia * dt) + (gravity * dt)

				local p0 = entity.state.position
				local p1 = entity.state.position + v0 * dt

				-- print(table_to_string(v1))
				-- v1 = v1 + g
				-- get chunks p0p1 passes thru
				-- if a p0p1 intersects a block

				entity.state.position = p1
				entity.state.velocity = v1

				entity:update(dt)

				-- TODO: inertia & gravity
			end)
		end,


		draw = function(self, view)
      local half_screen_height = view.screen_height / 2

      local half_screen_width = view.screen_width / 2

      local scale = view.zoom / style.terrain.native_zoom_scale

			forEachEntity(self.state.entities, function(entity)
				local eid = entity.eid

				local buffer = entity_buffers[eid]

	      local render_x = (entity.state.position.x * scale) - view.x + half_screen_width

	      local render_y = (entity.state.position.y * scale) - view.y + half_screen_height

	      -- print('render_x='..render_x..' position.x='..entity.state.position.x..' view.x='..view.x)
        if buffer == nil then 
          buffer = love.graphics.newCanvas(entity.state.width, entity.state.height)

          love.graphics.setCanvas(buffer)
          buffer:setFilter("linear", "nearest")
  				entity:draw()
          love.graphics.setCanvas()

          entity_buffers[eid] = buffer
        end

        love.graphics.setColor(entity.state.color)
        love.graphics.draw(buffer, render_x, render_y, 0, scale, scale)
        love.graphics.setColor(1.0,1.0,1.0,1.0)
			end)

		end,
	}
end
