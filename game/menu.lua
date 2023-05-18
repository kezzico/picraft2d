require 'button'
require 'background'

Menu = class:new()

menu_state = {
  select_index = 1,

  layer = "main",

  active = false,

  scroll_vector = { x = 1, y = 1.0 }
}

menu_components = {
  play_button = nil,

  quit_button = nil,
}

function Menu:load()
  menu_components.play_button = Button("PLAY", style.menu.button, { index = 1 })
  menu_components.quit_button = Button("QUIT", style.menu.button, { index = 2 })

  menu_components.create_world1_button = Button("World 1-1", style.menu.button, { index = 3 })
  menu_components.create_world2_button = Button("World 1-2", style.menu.button, { index = 4 })
  menu_components.create_world3_button = Button("World 1-4", style.menu.button, { index = 5 })
  menu_components.create_world4_button = Button("World 2-1", style.menu.button, { index = 6 })
  menu_components.create_world5_button = Button("World -1", style.menu.button, { index = 7 })

  menu_music = love.audio.newSource(style.menu.music, "stream")
  menu_music:setLooping(true)

  background = Background(style.menu.background_color)
end

function Menu:activate()
  menu_state.active = true
  menu_state.layer = "main"
  menu_state.select_index = 1

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

    elseif menu_state.select_index == 2 then
      love.event.quit()

    elseif menu_state.select_index == 3 then
      menu:suspend()
      game:load(12345, "generators/buildings.lua")
      game:activate()
    elseif menu_state.select_index == 4 then
      menu:suspend()
      game:load(12345, "generators/checkers.lua")
      game:activate()
    elseif menu_state.select_index == 5 then
      menu:suspend()
      game:load(12345, "generators/rolling-hills.lua")
      game:activate()
    elseif menu_state.select_index == 6 then
      menu:suspend()
      game:load(12345, "generators/flatworld.lua")
      game:activate()
    elseif menu_state.select_index == 7 then
      menu:suspend()
      game:load(12345, "generators/crash.lua")
      game:activate()
    end
  end

  delegate.press_start = function()
    menu:suspend()
    game:activate()
  end
  controllers[1].delegate = delegate
end

function Menu:suspend()
  menu_state.active = false

  love.audio.pause(menu_music)
end

function Menu:update(dt)
  if game.state.active == false then
    game.state.view.x = game.state.view.x + menu_state.scroll_vector.x
    game.state.view.y = game.state.view.y + menu_state.scroll_vector.y

    if game.state.view.y < -64.0 then
      menu_state.scroll_vector.y = 1.0
    elseif game.state.view.y > 64.0 then
      menu_state.scroll_vector.y = -1.0
    end

    if game.state.view.x > 96.0 then
      menu_state.scroll_vector.x = -1.0
    elseif game.state.view.x < 0.0 then
      menu_state.scroll_vector.x = 1.0
    end

  end
end

function Menu:draw()
  if menu_state.active == false then
    return
  end

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
    menu_components.create_world1_button:draw({
      button_x = mid_x - menu_components.play_button.width / 2.0, 
      button_y = 100, 
      highlight_index = menu_state.select_index
    })
    menu_components.create_world2_button:draw({
      button_x = mid_x - menu_components.play_button.width / 2.0, 
      button_y = 200, 
      highlight_index = menu_state.select_index
    })
    menu_components.create_world3_button:draw({
      button_x = mid_x - menu_components.play_button.width / 2.0, 
      button_y = 300, 
      highlight_index = menu_state.select_index
    })
    menu_components.create_world4_button:draw({
      button_x = mid_x - menu_components.play_button.width / 2.0, 
      button_y = 400, 
      highlight_index = menu_state.select_index
    })
    menu_components.create_world5_button:draw({
      button_x = mid_x - menu_components.play_button.width / 2.0, 
      button_y = 500, 
      highlight_index = menu_state.select_index
    })
  end
end

