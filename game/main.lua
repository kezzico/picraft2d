love.filesystem.setIdentity("picraft")

require 'class'
require 'table_to_string'
require 'game'
require 'menu'
require 'controller'
require 'style'
require 'cache'
require 'random'
require 'generator'
require 'terrain'
require 'text'
require 'simulation'
require 'entity'
require 'vector'

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
  game = Game()

  game:load(1234, "generators/rolling-hills.lua")

  menu = Menu:new()
  menu:load()

  menu:activate()
end


function love.update(dt)
  if dt > 0.1 then dt = 0.1 end

  global_state.screen_height = love.graphics.getHeight()
  global_state.screen_width = love.graphics.getWidth()

  controllers.player1.state = ControllerState()

  if love.keyboard.isDown("up") then 
    controllers.player1.state.up = 1.0
  end

  if love.keyboard.isDown("down") then 
    controllers.player1.state.down = 1.0
  end

  if love.keyboard.isDown("left") then 
    controllers.player1.state.left = 1.0
  end

  if love.keyboard.isDown("right") then 
    controllers.player1.state.right = 1.0
  end

  if love.keyboard.isDown("lshift") then
    controllers.player1.state.run = 1.0
  end

  menu:update(dt)
  game:update(dt)
end

function love.draw()
  game:draw()
  menu:draw()
end

function love.quit()
  game:suspend()
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
