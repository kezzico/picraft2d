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
		end
	}
end