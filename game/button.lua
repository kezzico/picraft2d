local love = require 'love'


function Button(text, style, defaults)
	defaults = defaults or { }

	local text_width = style.font:getWidth(text)
	local text_height = style.font:getHeight(text)

	return {
		width = style.width or 100,
		height = style.height or 100,
		index = defaults.index or 0,
		highlight_index = -1,

		draw = function(self, config)
			local text_x = (self.width - text_width) / 2.0
			local text_y = (self.height - text_height) / 2.0

			if config.highlight_index then
				self.highlight_index = config.highlight_index
			end

			if self.highlight_index == self.index then
				love.graphics.setColor(style.background_color_highlight)
			else
				love.graphics.setColor(style.background_color)
			end
			
			love.graphics.rectangle("fill", config.button_x, config.button_y, self.width, self.height)

			if self.highlight_index == self.index then
				love.graphics.setColor(style.text_color_highlight)
			else
				love.graphics.setColor(style.text_color)
			end

			love.graphics.setFont(style.font)
			love.graphics.print(text, config.button_x + text_x, config.button_y + text_y)


			love.graphics.setColor(0, 0, 0)
		end
	}

end

return Button
