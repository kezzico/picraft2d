require 'class'
require 'game'

love.filesystem.setIdentity("picraft")

game = nil

function love.load()
  game = Game:new()

  game:load()
end



function love.update(dt)
  if dt > 0.1 then dt = 0.1 end

  game:update(dt)
end



function love.draw()
  game:draw()
end

function love.quit()
  print("Thanks for playing. Please play again soon!")
end

function love.joystickadded(joystick)
  local jid = joystick:getID()

  -- local controller = Controller:new(joystick)

end

function love.joystickremoved(joystick)

end

function love.gamepadpressed(joystick, button)

end

function love.gamepadreleased(joystick, button)

end
