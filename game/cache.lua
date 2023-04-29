function Cache()
	local font_cache = { }
	return {
		font = function(fontname)
			local key = fontname[1]..','..fontname[2]

			local font = font_cache[key]

			if font == nil then
				font = love.graphics.newFont(fontname[1], fontname[2])

				font_cache[key] = font
			end

			return font
		end
	}
end