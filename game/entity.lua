local eid_increment = 0

local function next_eid()
	eid_increment = eid_increment + 1
	return eid_increment
end

function Entity(ent_style)
	local time_accum = 0

	local quads = cache.quads(ent_style)

	local spritesheet = cache.image(ent_style.imagepath)

	local frame = 1

	return {
		eid = next_eid(),
		
		state = {
			position = Vector.new(),

			velocity = Vector.new(),

			width = style.terrain.blocks_pixel_size,

			height = style.terrain.blocks_pixel_size,

			collision = false,

			color = { 1.0,1.0,1.0,1.0 },

			animation = ent_style.animations.run
		},
		update = function(self, dt)

			-- outputs from dt
			-- 0.016493250150234
			-- 0.021712749963626
			-- 0.016384999966249
			-- 0.015086957952008
			-- print(dt)

			-- self.state.animation_speed

			start_frame = self.state.animation[1]

			num_frames = #self.state.animation

			-- local frame_duration = self.state.animation_speed -- 15 frames

			-- local frame = start_frame + (duration / num_frames)

			-- frame = start_frame + end_frame

			local duration = 0.15
			time_accum = time_accum + dt
			if time_accum > duration then
				time_accum = time_accum - duration

				frame = frame + 1

				if frame > num_frames then frame = 1 end
			end

			-- self.state.animation_speed

			-- local f = math.floor(self.currentTime / self.duration * #self.quads) + 1

		end,

		draw = function(self)
	    local render_w = self.state.width

	    local render_h = self.state.height

      local sx = render_w / ent_style.frame_width

			local sy = render_h / ent_style.frame_height

			local flip_x = 0

			if self.state.velocity.x < 0 then
				flip_x = render_w 
				sx = -sx
			end

			local quad_index = self.state.animation[frame]
-- print('frame:'..frame..'index:'..quad_index)
-- print('index:'..quad_index)
-- print(table_to_string(quads))
			local quad = quads[quad_index]

			love.graphics.setColor(1,1,1,1)
			love.graphics.draw(spritesheet, quad, flip_x, 0, 0, sx,sy)
		end
	}

end








-- function Sprite(style)
-- 	local image = cache.image(style.imagepath)

-- 	local image_width = image:getWidth()

-- 	local image_height = image:getHeight()

-- 	local last_frame_time = -1

-- 	local function make_quads()
-- 		local num_hcells = math.floor(image_width / style.frame_width)
-- 		local num_vcells = math.floor(image_height / style.frame_height)
-- 		local num_quads = num_hcells * num_vcells
-- 		local quads = { }
-- 		for frame = 0, num_quads do
-- 			local offset_x = (frame % num_vcells) * image_width

-- 			local offset_y = (frame / num_hcells) * image_height

-- 			local quad = love.graphics.newQuad(
-- 				offset_x, offset_y, 
-- 				style.frame_width, style.frame_height,
-- 				image_width, image_height)

-- 	    	table.insert(quads, quad)
-- 	    end

-- 		return quads
-- 	end

-- 	local quads = make_quads()
		
-- 	return {
-- 		state = {
-- 			animation = animations.stand,

-- 			animation_speed = 0 -- fps,

-- 			frame = 0
-- 		},

-- 		update = function(self, dt)

-- 			last_frame_time = dt
-- 		end,

-- 		draw = function(self)
-- 			local quad = self.quads[self.state.frame]
-- -- not sure how to draw quad
-- 			love.graphics.draw(image, quad, x, y, 0, 4)
-- 		end
-- 	}

--     -- self.spriteSheet = image;

-- 	-- self.quads = {};

-- 	-- for frame = 0, frames-1 do
-- 	-- 	local offset_x = frame * height

-- 	-- 	local quad = love.graphics.newQuad(offset_x, 0, height, height, width, height)

--     -- 	table.insert(self.quads, quad)
--     -- end
 
--     -- self.duration = duration or 1
		
--     -- self.currentTime = 0
-- end

-- -- function Animation:draw(x, y)	
-- -- 	local f = math.floor(self.currentTime / self.duration * #self.quads) + 1
	
-- -- 	love.graphics.draw(self.spriteSheet, self.quads[f], x, y, 0, 4)
-- -- end
-- --  