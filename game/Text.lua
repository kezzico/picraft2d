function Text(text, style, defaults)
	defaults = defaults or { }

	local font = cache.font(style.fontname)

	local text_width = font:getWidth(text)

	local text_height = font:getHeight(text)

	return {
		state = {
			color = style.text_color,
			text_x = defaults.x or 0, 
			text_y = defaults.y or 0
		},

		width = text_width,

		height = text_height,

		draw = function(self, config)
			love.graphics.setColor(style.text_color)

			love.graphics.setFont(font)

			love.graphics.print(text, 
				self.state.text_x, self.state.text_y)

			love.graphics.setColor(1, 1, 1, 1)
		end
	}
end
