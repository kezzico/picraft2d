love.filesystem.setIdentity("picraft")

require 'class'
require 'table_to_string'
require 'game'
require 'menu'
require 'controller'
require 'style'
require 'cache'

game = nil
menu = nil

global_state = {
  screen_height = 0,
  
  screen_width = 0,
}

controllers = {
  player1 = Controller()
}

cache = Cache()


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

  menu:update(dt)
  game:update(dt)
end

function love.draw()
  game:draw()
  menu:draw()
end

function love.quit()
  game_state.generator:stop()

  print("Thanks for playing. Please play again soon!")
end


function love.keypressed(key, u)
  local controller = controllers.player1
  if key == "up" then
    controller.delegate:press_up()
  elseif key == "down" then
    controller.delegate:press_down()
  end

  if key == "left" then
    controller.delegate.press_left()
  elseif key == "right" then
    controller.delegate.press_right()
  end

  if key == "return" then
    controller.delegate.press_x()
  end

  if key == "escape" then
    controller.delegate.press_start()
  end

  if key == "c" then
    controller.delegate.press_function_1()
  end
  if key == "v" then
    controller.delegate.press_function_2()
  end
  if tonumber(key) ~= nil then
    print(key)
    controller.delegate.press_number(tonumber(key))
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
