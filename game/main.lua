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
  Controller(), Controller()
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

  for i=1,#controllers do
    local state = ControllerState()
    local joystick = love.joystick.getJoysticks()[i]
    
    if joystick ~= nil then
      if joystick:isGamepadDown("dpup") then state.up = 1.0 end
      if joystick:isGamepadDown("dpdown") then state.down = 1.0 end
      if joystick:isGamepadDown("dpleft") then state.left = 1.0 end
      if joystick:isGamepadDown("dpright") then state.right = 1.0 end
      if joystick:isGamepadDown("a") then state.run = 1.0 end
    end
    if i == 1 then
      if love.keyboard.isDown("up") then state.up = 1.0 end
      if love.keyboard.isDown("down") then state.down = 1.0 end
      if love.keyboard.isDown("left") then state.left = 1.0 end
      if love.keyboard.isDown("right") then state.right = 1.0 end
      if love.keyboard.isDown("lshift") then state.run = 1.0 end
    end

    controllers[i].state = state
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
  local controller = controllers[1]

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

function love.gamepadpressed(joystick, button)
  for i=1, #controllers do
    local controller = controllers[i]

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
end
