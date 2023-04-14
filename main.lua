local love = require 'love'

require 'class'
require 'game'
require 'menu'

love.filesystem.setIdentity("picraft")

game = nil

menu = nil

global_state = {
  screenHeight = 0,
  
  screenWidth = 0
}


function love.load()
  -- game = Game:new()

  -- game:load()

  menu = Menu:new()

  menu:load()
end


function love.update(dt)
  if dt > 0.1 then dt = 0.1 end

  global_state.screen_height = love.graphics.getHeight()
  
  global_state.screen_width = love.graphics.getWidth()

  menu:update(dt)
  -- game:update(dt)
end

function love.draw()
  menu:draw()

  -- game:draw()
end

function love.quit()
  print("Thanks for playing. Please play again soon!")
end

function love.joystickadded(joystick)
  local jid = joystick:getID()
end

function love.joystickremoved(joystick)

end

function love.gamepadpressed(joystick, button)

end

function love.gamepadreleased(joystick, button)

end
