
function Background(color) 
	color.r = color.r or 0
	color.g = color.g or 0
	color.b = color.b or 0
	color.a = color.a or 1

  return {
    draw = function()
      love.graphics.setColor(color.r, color.g, color.b, color.a)
      love.graphics.rectangle("fill", 0,0, 
        global_state.screen_width, global_state.screen_height)

      love.graphics.setColor(0,0,0,1)

    end
  }
end