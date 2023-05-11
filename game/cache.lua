function Cache()
	local font_cache = { }

	local image_cache = { }
	
	return {
		font = function(fontname)
			local key = fontname[1]..','..fontname[2]

			local font = font_cache[key]

			if font == nil then
				print("load font")
				font = love.graphics.newFont(fontname[1], fontname[2])

				font_cache[key] = font
			end

			return font
		end,

		image = function(imagename)
			local key = imagename

			local image = image_cache[key]

			if image == nil then
				image = love.graphics.newImage(key, { })

				image_cache[key] = image
			end

			return image
		end,

		quads = function(ent_style)
			local key = ent_style.imagepath

			local image = image_cache[key]

			if image == nil then
				image = love.graphics.newImage(key, { })

				image_cache[key] = image
			end

			local image_width = image:getWidth()

			local image_height = image:getHeight()

			local num_hcells = math.floor(image_width / ent_style.frame_width)

			local num_vcells = math.floor(image_height / ent_style.frame_height)

			local num_quads = num_hcells * num_vcells

			local quads = { }

			for frame = 1, num_quads do
				local offset_x = ((frame-1) % num_hcells) * ent_style.frame_width

				local offset_y = math.floor((frame-1) / num_hcells) * ent_style.frame_height

				print(frame..' '..offset_x..' '..offset_y)
				local quad = love.graphics.newQuad(
					offset_x, offset_y, 
					ent_style.frame_width, ent_style.frame_height,
					image)

				table.insert(quads, quad)
		    end

			return quads
		end
	}
end