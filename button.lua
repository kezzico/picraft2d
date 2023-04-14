local love = require 'love'
require 'menu_style'


function Button(text, defaults, func)
	defaults = defaults or { }

	return {
		width = defaults.width or 100,
		height = defaults.height or 100,
		func = func or function() print("no func") end,
		text = text or "empty",
		button_x = 0,
		button_y = 0,
		text_x = defaults.text_x or 0,
		text_y = defaults.text_y or 0,
		font = defaults.font or font,
		index = defaults.index or 0,
		highlight_index = -1,

		draw = function(self, config)
			self.button_x = config.button_x
			self.button_y = config.button_y

			if config.highlight_index then
				self.highlight_index = config.highlight_index
			end

			if config.text_x then
				self.text_x = config.text_x
			end

			if config.text_y then
				self.text_y = config.text_y
			end

-- print("hi "..self.button_x.." "..self.button_y.." "..self.width.." "..self.height)
			if self.highlight_index == self.index then
				love.graphics.setColor(255, 0, 0)
			else
				love.graphics.setColor(255, 255, 255)
			end
			
			love.graphics.rectangle("fill", self.button_x, self.button_y, self.width, self.height)

			if self.highlight_index == self.index then
				love.graphics.setColor(255, 255, 255)
			else
				love.graphics.setColor(255, 0, 0)
			end

			love.graphics.setFont(font)
			love.graphics.print(self.text, self.button_x + self.text_x, self.button_y + self.text_y)

			love.graphics.setColor(0, 0, 0)
		end
	}

end

return Button
