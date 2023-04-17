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
  screen_height = 0,
  
  screen_width = 0,
}

controllers = {
  player1 = Controller()
}


function love.load()
  game = Game:new()
  game:load()
  game:activate()

  menu = Menu:new()
  menu:load()

  menu:activate()
end


function love.update(dt)
  if dt > 0.1 then dt = 0.1 end

  global_state.screen_height = love.graphics.getHeight()
  global_state.screen_width = love.graphics.getWidth()

  menu:update(dt)
  game:update(dt)
end

function love.draw()
  game:draw()
  menu:draw()
end

function love.quit()
  print("Thanks for playing. Please play again soon!")
end


function love.keypressed(key, u)
  if key == "up" then
    controllers.player1.delegate:press_up()
  elseif key == "down" then
    controllers.player1.delegate:press_down()
  end

  if key == "return" then
    controllers.player1.delegate.press_x()
  end

  if key == "escape" then
    controllers.player1.delegate.press_start()
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
  local controller = controllers.player1

  if button == "dpup" then
    controller.delegate.press_up()
  elseif button == "dpdown" then
    controller.delegate.press_down()
  end

  if button == "dpleft" then
    controller.delegate.press_left()
  elseif button == "dpright" then
    controller.delegate.press_right()
  end

  if button == "a" then
    controller.delegate.press_x()
  end

  if button == "start" then
    controller.delegate.press_start()
  end

end

function love.gamepadreleased(joystick, button)

end
