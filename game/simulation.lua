function Simulation(seed)
	local entity_buffers = { }

	local function forEach(table_1dex, callback)
		for i=1, #table_1dex do
			callback(table_1dex[i])
		end
	end

	local function positionToChunkRC(position)	
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

			forEach(self.state.entities, function(entity)
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
			-- local gravity = Vector.new(0,0.0)

			local inertia = -0.0165 * 32

		  local block_w = style.terrain.blocks_pixel_size

		  local block_h = style.terrain.blocks_pixel_size

		  local chunk_w = style.terrain.blocks_per_chunk * block_w

		  local chunk_h = style.terrain.blocks_per_chunk * block_h

			forEach(self.state.entities, function(entity)
				local chunkrc = positionToChunkRC(entity.state.position)

				local chunk = chunks[chunkrc]

				if chunk == nil then return end

        local chunk_xy = Vector.new(chunk_w*chunk.c, chunk_h*chunk.r)

				local v0 = entity.state.velocity
				local p0 = entity.state.position

				local p1 = p0 + v0 * dt
				local v1 = v0 + (v0 * inertia * dt) + (gravity * dt)

				forEach(collision_barriers(chunk.front), function(barrier)
					local b0 = Vector.new(barrier[1][1], barrier[1][2]) + chunk_xy

					local b1 = Vector.new(barrier[2][1], barrier[2][2]) + chunk_xy

					local b = b1 - b0

					if linesCanIntersect(b0, b1, p0, p1) == false then
						return
					end

					-- horizontal barrier
					if math.abs(b.x) > 0 then
						p1.y = p0.y
						v1.y = 0

					-- vertical barrier
					elseif b.y < 0 then
						p1.x = p0.x
						v1.x = 0
					elseif b.y > 0 then
						p1.x = p0.x - entity.state.width
						v1.x = 0
					end
					-- print(table_to_string(b0))

					-- print(table_to_string(b0-b1))

				end)

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

			forEach(self.state.entities, function(entity)
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


function triangleDirection(pt1, pt2, pt3)
  local test = ((pt2.x - pt1.x) * (pt3.y - pt1.y)) - ((pt3.x - pt1.x) * (pt2.y - pt1.y))
  if test > 0 then
    return "TriangleDirectionCounterClockwise"
  elseif test < 0 then
    return "TriangleDirectionClockwise"
  else
    return "TriangleDirectionNone"
  end
end

-- function triangleDirection(pt1, pt2, pt3)
--   local test = ((pt2[1] - pt1[1]) * (pt3[2] - pt1[2])) - ((pt3[1] - pt1[1]) * (pt2[2] - pt1[2]))
--   if test > 0 then
--     return "TriangleDirectionCounterClockwise"
--   elseif test < 0 then
--     return "TriangleDirectionClockwise"
--   else
--     return "TriangleDirectionNone"
--   end
-- end

function linesCanIntersect(l1p1, l1p2, l2p1, l2p2)
  local test1_a, test1_b, test2_a, test2_b
  
  test1_a = triangleDirection(l1p1, l1p2, l2p1)
  test1_b = triangleDirection(l1p1, l1p2, l2p2)
  if test1_a ~= test1_b then
    test2_a = triangleDirection(l2p1, l2p2, l1p1)
    test2_b = triangleDirection(l2p1, l2p2, l1p2)
    if test2_a ~= test2_b then
      return true
    end
  end
  return false
end
