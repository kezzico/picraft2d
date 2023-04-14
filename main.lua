local love = require 'love'

require 'class'
require 'game'
require 'menu'

love.filesystem.setIdentity("picraft")

game = nil

menu = nil

global_state = {
  screenHeight = 0,
  
  screenWidth = 0,

  menu_active = true
}


function love.load()
  game = Game:new()

  game:load()

  menu = Menu:new()

  menu:load()
end


function love.update(dt)
  if dt > 0.1 then dt = 0.1 end

  global_state.screen_height = love.graphics.getHeight()
  
  global_state.screen_width = love.graphics.getWidth()

  if global_state.menu_active == true then
    menu:update(dt)
  else
    game:update(dt)
  end
end

function love.draw()
  if global_state.menu_active == true then
    menu:draw()
  else
    game:draw()
  end

end

function love.quit()
  print("Thanks for playing. Please play again soon!")
end

function love.keypressed(k, u)
  print(k)

  if global_state.menu_active == true then
    menu:keypressed(k)
  else

  end  
end

function love.joystickadded(joystick)
  local jid = joystick:getID()
  if global_state.menu_active == true then
  
  else

  end  

end

function love.joystickremoved(joystick)

end

function love.gamepadpressed(joystick, button)

end

function love.gamepadreleased(joystick, button)

end
