love.filesystem.load("perlin.lua")()
love.filesystem.load("chunk.lua")()
-- love.filesystem.load("terrain.lua")()
-- love.filesystem.load("grapplinghook.lua")()
-- love.filesystem.load("player.lua")()
-- love.filesystem.load("collision.lua")()
love.filesystem.load("common.lua")()
-- love.filesystem.load("entity.lua")()
-- love.filesystem.load("gameplay.lua")()
-- love.filesystem.load("inventory.lua")()

require 'generator'
require 'terrain'
anim8 = require 'anim8/anim8'

-- showPerlin = false
-- oldMouse = {x = 0, y = 0}
-- cursor = {x = 0, y = 0}
-- cursorFade = false
-- cursorAlpha = 255
-- inreach = true
-- mineBlock = {r = nil, c = nil}
-- mineProgress = 0
-- placeTime = 0
-- instamine = false
-- debug = false
-- hookRelease = false
-- showInventory = false
-- g = 40

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

  game_state.generator = Generator("generators/perlin.lua")

  game_state.terrain = Terrain(seed, game_state.generator)

  game_state.generator:start()

  game_state.view.x = 0

  game_state.view.y = 0

  game_state.view.zoom = style.terrain.native_zoom_scale / 4
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

  controllers.player1.delegate = delegate
end

function Game:suspend()

end


function Game:update(dt)
  local terrain = game_state.terrain

  local view = game_state.view

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





  -- while terrain:getBlock(math.floor(view.y), math.floor(view.x) + 1) == AIR do
  --   view.y = view.y + 1
  -- end
  -- while terrain:getBlock(math.floor(view.y), math.floor(view.x) + 1) ~= AIR do
  --   view.y = view.y - 1
  -- end

  -- player = Player:new()
  -- player.x = 0.5
  -- player.y = -60
  -- while terrain:getBlock(math.floor(player.y), math.floor(player.x) + 1) == AIR do
  --   player.y = player.y + 1
  -- end
  -- while terrain:getBlock(math.floor(player.y), math.floor(player.x) + 1) ~= AIR do
  --   player.y = player.y - 1
  -- end

  -- view.x = player.x
  -- view.y = player.y - player.height / 2

  -- player.inventory:give(WOOD_SHOVEL) -- Just temporary, for testing





  -- love.graphics.setColor(255, 255, 255, 255)
  -- player:draw(view)

  -- love.graphics.setColor(0, 0, 0, cursorAlpha)
  -- if inreach and not showInventory then
  --   love.graphics.setLineWidth(view.zoom/32)
  --   love.graphics.setLineStyle("rough")
  --   love.graphics.rectangle("line", (math.ceil(cursor.x)-1-view.x)*view.zoom + love.graphics.getWidth()/2, (math.ceil(cursor.y)-1-view.y)*view.zoom+love.graphics.getHeight()/2, view.zoom, view.zoom)
  -- end

  -- if mineProgress > 0 and mineProgress <= 1 then
  --   love.graphics.draw(breakImage[math.ceil(mineProgress * 8)], (mineBlock.c-1-view.x)*view.zoom + love.graphics.getWidth()/2, (mineBlock.r-1-view.y)*view.zoom+love.graphics.getHeight()/2, 0, view.zoom/16, view.zoom/16)
  -- end

  -- if showInventory then
  --   player.inventory:draw()
  -- else
  --   player.inventory:drawHotbar()
  -- end

  -- if debug then
  --   love.graphics.setColor(0, 0, 0, 255)
  --   love.graphics.print(love.timer.getFPS() .. " fps", love.graphics.getWidth() - 150, 50)
  -- end








  -- if dt > 0.1 then dt = 0.1 end
  -- local oldx = player.x
  -- local oldy = player.y
  -- if not first then
  --   player:update(dt)
  -- end

  -- for i = 1, #terrain.entities do
  --   local entity = terrain.entities[i]
  --   if entity.falling then
  --     entity.vy = entity.vy + g * dt
  --     entity.y = entity.y + entity.vy * dt
  --   end
  -- end

  -- checkCollisions(terrain, player)

  -- if showInventory then handleInventoryInput(player)
  -- else handleGameplayInput(player, terrain, dt)
  -- end

  -- view.x = view.x + (player.x - view.x) * 0.2
  -- view.y = view.y + (player.y - player.height / 2 - view.y) * 0.2
  -- local viewDist = pythag(view.x, view.y, player.x, player.y)
  -- local maxViewDist = 0.35 * math.min(love.graphics.getWidth(), love.graphics.getHeight()) / view.zoom
  -- if viewDist > maxViewDist then
  --   view.x = player.x - (player.x - view.x) * (maxViewDist / viewDist)
  --   view.y = player.y - (player.y - view.y) * (maxViewDist / viewDist)
  -- end
  -- first = false

  -- placeTime = placeTime + dt
  -- player.walk:update(dt)
  -- player.hook:update(terrain, dt)

  -- Generate new chunks
  -- local view = game_state.view
  -- for r = math.floor((view.y - 80) / 32), math.floor((view.y + 80) / 32) do
  --   for c = math.floor((view.x - 80) / 32), math.floor((view.x + 80) / 32) do
  --     terrain:generate(r, c)
  --   end
  -- end

  -- terrain:checkGenerator()
