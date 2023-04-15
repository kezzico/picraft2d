local love = require 'love'
love.filesystem.setIdentity("picraft")

require 'class'
require 'table_to_string'
require 'game'
require 'menu'
require 'style'

game = nil
menu = nil

global_state = {
  screenHeight = 0,
  
  screenWidth = 0,

  menu_active = true,

  controllers = { }
}


function love.load()
  game = Game:new()

  game:load()

  menu = Menu:new()

  menu:load()
  menu:activate()
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
    game:draw()

  if global_state.menu_active == true then
    menu:draw()
  else
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
  print(table_to_string(love.joystick.getJoysticks()[1].getName()))
  local jid = joystick:getID()
  if global_state.menu_active == true then
  
  else

  end  
end

function love.joystickremoved(joystick)
  print(table_to_string(love.joystick.getJoysticks()))

end

function love.gamepadpressed(joystick, button)
  print("poo2"..table_to_string(joystick).." "..button)
end

function love.gamepadreleased(joystick, button)

end
