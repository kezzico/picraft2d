local love = require 'love'
love.filesystem.setIdentity("picraft")

require 'class'
require 'table_to_string'
require 'game'
require 'menu'
require 'controller'
require 'style'

game = nil
menu = nil

global_state = {
  screenHeight = 0,
  
  screenWidth = 0,

  menu_active = true,

  controller_player1 = Controller()
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
    -- hud:draw
  end

end

function love.quit()
  print("Thanks for playing. Please play again soon!")
end


function love.keypressed(key, u)
  local controller = global_state.controller_player1
  if key == "up" then
    controller.delegate:press_up()
  elseif key == "down" then
    controller.delegate:press_down()
  end

  if key == "return" then
    controller.delegate.press_x()
  end

  if key == "escape" then
    if global_state.menu_active then
      game:activate()
      menu:suspend()
      global_state.menu_active = false
    else
      menu:activate()
      game:suspend()
      global_state.menu_active = true
    end
  end

end

function love.joystickadded(joystick)
  local jid = joystick:getID()
  print("jid:"..jid)
end

function love.joystickremoved(joystick)
  print(table_to_string(love.joystick.getJoysticks()))

end

function love.gamepadpressed(joystick, button)
  local controller = global_state.controller_player1
  print(button)  
  if button == "dpup" then
    global_state.controller_player1.delegate.press_up()
  elseif button == "dpdown" then
    global_state.controller_player1.delegate.press_down()
  end

  if button == "a" then
    global_state.controller_player1.delegate.press_x()
  end

  if button == "start" then
    if global_state.menu_active then
      game:activate()
      menu:suspend()
      global_state.menu_active = false
    else
      menu:activate()
      game:suspend()
      global_state.menu_active = true
    end
  end

end

function love.gamepadreleased(joystick, button)

end
