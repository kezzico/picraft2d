require 'button'
require 'menu_style'

Menu = class:new()

menu_state = {
  highlight_button_index = 1
}

buttons = {

}



function Menu:load()
  buttons.play_button = Button("PLAY", { width = 200, height = 64, text_x = 55, text_y = 11, index = 1 })
  buttons.quit_button = Button("QUIT", { width = 200, height = 64, text_x = 55, text_y = 11, index = 2 })

  -- game = Game:new()

  -- game:load()
end

function Menu:keypressed(key)
  if key == "up" then
    menu_state.highlight_button_index = menu_state.highlight_button_index - 1
  elseif key == "down" then
    menu_state.highlight_button_index = menu_state.highlight_button_index + 1
  end

  if key == "return" then
    global_state.menu_active = false
  end
end

function Menu:update(dt)
end

function Menu:draw()
  local mid_x = global_state.screen_width / 2.0
  buttons.play_button:draw({ 
    button_x = mid_x - buttons.play_button.width / 2.0, 
    button_y = 100, 
    highlight_index = menu_state.highlight_button_index
  })

  buttons.quit_button:draw({
    button_x = mid_x - buttons.quit_button.width / 2.0, 
    button_y = 200,
    highlight_index = menu_state.highlight_button_index
  })
end

