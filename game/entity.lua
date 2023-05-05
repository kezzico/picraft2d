local eid_increment = 0

local function next_eid()
	eid_increment = eid_increment + 1
	return eid_increment
end

function Entity(type, position)
	return {
		eid = next_eid(),
		
		state = {
			position = Vector.new(),

			velocity = Vector.new(),

			width = style.terrain.blocks_pixel_size,

			height = style.terrain.blocks_pixel_size,

			collision = false,

			color = { 1.0,1.0,1.0,1.0 }
		},
		update = function(self, dt)
				self.state.position = self.state.position + (self.state.velocity * dt)
		end,

		draw = function(self)
	    local render_w = self.state.width

	    local render_h = self.state.height

      local t = type

      if t ~= nil then
        local texture = cache.image('textures/bricks_overworld.png')
        local sx = render_w / texture:getWidth()
        local sy = render_h / texture:getHeight()

        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(texture,render_x,render_y,0,sx,sy)
      else
        print("unknown entity type ".. table_to_string(t))
      end
		end
	}

end
