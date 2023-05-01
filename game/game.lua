require 'generator'
require 'terrain'

Game = class:new()
game_state = {
  view = { zoom = 1, x = 0, y = 0},

  active = false,

  terrain = nil,

  generator = nil
}

function Game:init()

end

function Game:load()
  local seed = os.time()

  game_state.generator = Generator(seed, "generators/rolling-hills.lua")

  game_state.terrain = Terrain(game_state.generator)

  game_state.generator:start()

  game_state.view.x = 0

  game_state.view.y = 0

  game_state.view.zoom = style.terrain.native_zoom_scale
end


function Game:activate()
  game_state.active = true

  local delegate = ControllerDelegate()

  delegate.press_start = function()
    game:suspend()

    menu:activate()
  end

  delegate.press_left = function()
    game_state.view.x = game_state.view.x - 256 * game_state.view.zoom / style.terrain.native_zoom_scale
  end

  delegate.press_right = function()
    game_state.view.x = game_state.view.x + 256 * game_state.view.zoom / style.terrain.native_zoom_scale
  end

  delegate.press_up = function()
    game_state.view.y = game_state.view.y - 256 * game_state.view.zoom / style.terrain.native_zoom_scale
  end

  delegate.press_down = function()
    game_state.view.y = game_state.view.y + 256 * game_state.view.zoom / style.terrain.native_zoom_scale
  end

  delegate.press_function_1 = function()
    local terrain = game_state.terrain

    local toggle = not terrain.state.render_chunk_borders

    terrain.state.render_chunk_borders = toggle
  end

  delegate.press_function_2 = function()
    local terrain = game_state.terrain

    local toggle = not terrain.state.render_chunks

    terrain.state.render_chunks = toggle
  end

  delegate.press_number = function(n)
    game_state.view.zoom = style.terrain.native_zoom_scale/10 * (10-n)
  end

  controllers.player1.delegate = delegate
end

function Game:suspend()

end


function Game:update(dt)
  local terrain = game_state.terrain

  local view = game_state.view

  terrain:clean(view)
  terrain:generate(view)
end



function Game:draw()
  game_state.terrain:draw(game_state.view)
end




function pythag(x1, y1, x2, y2)
  if x2 == nil and y2 == nil then
    x2 = 0
    y2 = 0
  end
  return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end
