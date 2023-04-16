require 'button'
require 'background'

Menu = class:new()

menu_state = {
  select_index = 1,

  layer = "main"
}

menu_components = {
  play_button = nil,

  quit_button = nil,

  create_world_button = nil,
}

function Menu:load()
  menu_components.play_button = Button("PLAY", style.menu.button, { index = 1 })
  menu_components.quit_button = Button("QUIT", style.menu.button, { index = 2 })

  menu_components.create_world_button = Button("Create World", style.menu.button, { index = 3 })

  menu_music = love.audio.newSource(style.menu.music, "stream")
  menu_music:setLooping(true)

  background = Background(style.menu.background_color)
end

function Menu:activate()
  love.audio.play(menu_music)

  local delegate = ControllerDelegate()

  delegate.press_up = function()
    menu_state.select_index = menu_state.select_index - 1
  end

  delegate.press_down = function()
    menu_state.select_index = menu_state.select_index + 1
  end

  delegate.press_x = function()
    if menu_state.select_index == 1 then
      menu_state.layer = "select-world"
      menu_state.select_index = 3
    elseif menu_state.select_index == 3 then
      menu_state.layer = "main"
      menu_state.select_index = 1
      global_state.menu_active = false
    end

  end

  global_state.controller_player1.delegate = delegate
end

function Menu:suspend()
  love.audio.pause(menu_music)
end

function Menu:update(dt)
end

function Menu:draw()
  local mid_x = global_state.screen_width / 2.0

  background:draw()

  if menu_state.layer == "main" then
    menu_components.play_button:draw({
      button_x = mid_x - menu_components.play_button.width / 2.0, 
      button_y = 100, 
      highlight_index = menu_state.select_index
    })

    menu_components.quit_button:draw({
      button_x = mid_x - menu_components.quit_button.width / 2.0, 
      button_y = 200,
      highlight_index = menu_state.select_index
    })
  end


  if menu_state.layer == "select-world" then
    menu_components.create_world_button:draw({
      button_x = mid_x - menu_components.play_button.width / 2.0, 
      button_y = 100, 
      highlight_index = menu_state.select_index
    })
  end
end

