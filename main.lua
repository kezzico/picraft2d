love.filesystem.load("perlin.lua")()
love.filesystem.load("chunk.lua")()
love.filesystem.load("terrain.lua")()
love.filesystem.load("player.lua")()
love.filesystem.load("collision.lua")()
love.filesystem.load("common.lua")()
love.filesystem.load("loadgraphics.lua")()
love.filesystem.load("AnAL.lua")()
love.filesystem.setIdentity("lovecraft")

view = {zoom = 32, x = 0, y = 0}
showPerlin = false
oldMouse = {x = 0, y = 0}
cursor = {x = 0, y = 0}
cursorFade = false
cursorAlpha = 255
inreach = true
selected = 1
mineBlock = {r = nil, c = nil}
mineProgress = 0
placeTime = 0
landTime = 0
entities = {}
instamine = false
debug = false



function love.load()
  generator = love.thread.newThread("generator", "generator.lua")
  generator:start()
  
  player = Player:new()
  terrain = Terrain:new()
  terrain:generateInitial()
  player.x = 0.5
  player.y = -60
  while terrain:getBlock(math.floor(player.y), math.floor(player.x) + 1) == AIR do
    player.y = player.y + 1
  end
  while terrain:getBlock(math.floor(player.y), math.floor(player.x) + 1) ~= AIR do
    player.y = player.y - 1
  end
  
  view.x = player.x
  view.y = player.y - player.height / 2
  first = true
end



function love.update(dt)
  if dt > 0.2 then dt = 0.2 end
  local oldx = player.x
  local oldy = player.y
  if not first and player.falling then
    player.vy = player.vy + 40 * dt
    if     love.keyboard.isDown("a") and not player.againstLeftWall  then
      player.vx = math.max(-8, player.vx - 16 * dt)
      player.direction = -1
      landTime = 0
    elseif love.keyboard.isDown("d") and not player.againstRightWall then
      player.vx = math.min( 8, player.vx + 16 * dt)
      player.direction = 1
      landTime = 0
    end
  end
  if not first and not player.falling then
    if     love.keyboard.isDown("a") and not player.againstLeftWall  then
      player.vx = math.max(-8, player.vx - 36 * dt)
      player.direction = -1
      landTime = 0
    elseif love.keyboard.isDown("d") and not player.againstRightWall then
      player.vx = math.min( 8, player.vx + 36 * dt)
      player.direction = 1
      landTime = 0
    elseif player.vx > 0 then player.vx = math.max(0, player.vx - 128 * dt)
    elseif player.vx < 0 then player.vx = math.min(0, player.vx + 128 * dt)
    end
  end
  player.x = player.x + player.vx * dt
  player.y = player.y + player.vy * dt
  
  if not player.falling and math.abs(player.vx) > 0.5 and (love.keyboard.isDown("a") or love.keyboard.isDown("d")) then
    if not player.walking then player.walk:seek(5) end
    player.walking = true
  else
    player.walking = false
  end
  
  checkCollisions(terrain, player)
  
  if love.keyboard.isDown("w") and not player.falling then
    player.falling = true
    player.vy = -15
  end
  
  view.x = view.x + (player.x - view.x) * 0.2
  view.y = view.y + (player.y - player.height / 2 - view.y) * 0.2
  local viewDist = pythag(view.x, view.y, player.x, player.y)
  local maxViewDist = 0.35 * math.min(love.graphics.getWidth(), love.graphics.getHeight()) / view.zoom
  if viewDist > maxViewDist then
    view.x = player.x - (player.x - view.x) * (maxViewDist / viewDist)
    view.y = player.y - (player.y - view.y) * (maxViewDist / viewDist)
  end
  --view.x = player.x
  --view.y = player.y + player.height / 2
  first = false
  
  cursor.x = (love.mouse.getX() - love.graphics.getWidth()  / 2) / view.zoom + view.x
  cursor.y = (love.mouse.getY() - love.graphics.getHeight() / 2) / view.zoom + view.y
  if love.keyboard.isDown("w") or love.keyboard.isDown("a") or love.keyboard.isDown("s") or love.keyboard.isDown("d") then
    cursorFade = true
  end
  if love.mouse.getX() ~= oldMouse.x or love.mouse.getY() ~= oldMouse.y or love.mouse.isDown("l") or love.mouse.isDown("r") then
    cursorFade = false
    cursorAlpha = 255
  end
  if cursorFade then cursorAlpha = math.max(0, cursorAlpha - dt * 255 / 5) end
  oldMouse.x = love.mouse.getX()
  oldMouse.y = love.mouse.getY()
  
  inreach = (pythag(cursor.x, cursor.y, player.x, player.y - player.height/2) < 5)
  if inreach then
    local block = terrain:getBlock(math.ceil(cursor.y), math.ceil(cursor.x))
    if love.mouse.isDown("l") and block ~= AIR and block ~= UNGENERATED then
      if math.ceil(cursor.x) == mineBlock.c and math.ceil(cursor.y) == mineBlock.r then
        mineProgress = mineProgress + dt / durability[block]
        if mineProgress >= 1 or instamine then
          player:give(breakGive[block])
          terrain:setBlock(math.ceil(cursor.y), math.ceil(cursor.x), AIR)
          mineProgress = 0
          mineBlock.r = nil
          mineBlock.c = nil
        end
      else
        mineBlock.r = math.ceil(cursor.y)
        mineBlock.c = math.ceil(cursor.x)
        mineProgress = dt / durability[block]
      end
    elseif love.mouse.isDown("r") and block == AIR and placeTime > 0.2 then
    
      -- Temporary hack, change later
      if selected == 1 then block = DIRT
      elseif selected == 2 then block = STONE
      elseif selected == 3 then block = COBBLESTONE
      elseif selected == 4 then block = COAL_ORE
      elseif selected == 5 then block = WOOD
      end
      -- end hack
      
      local x = math.ceil(cursor.x)
      local y = math.ceil(cursor.y)
      if x - 1 >= player.x + player.width / 2 or x <= player.x - player.width / 2
      or y - 1 >= player.y or y <= player.y - player.height then
        if player:take(block) then
          terrain:setBlock(y, x, block)
          placeTime = 0
        end
      end
      mineProgress = 0
    else
      mineProgress = 0
    end
  end
  
  placeTime = placeTime + dt
  landTime = landTime - dt
  player.walk:update(dt)
  
  -- Generate new chunks
  for r = math.floor((player.y - 80) / 32), math.floor((player.y + 80) / 32) do
    for c = math.floor((player.x - 80) / 32), math.floor((player.x + 80) / 32) do
      terrain:generate(r, c)
    end
  end
  terrain:checkGenerator()
end



function love.draw()
  local x, y = love.mouse.getPosition()
  if showPerlin then drawTerrainPerlin(terrain, view.zoom, view.x, view.y)
  else
    love.graphics.setColor(161, 235, 255, 255)
    love.graphics.rectangle("fill", -1, -1, love.graphics.getWidth()+2, love.graphics.getHeight()+2)
    drawTerrain(terrain, view.zoom, view.x, view.y)
  end
  love.graphics.setColor(255, 255, 255, 255)
  if player.walking then
    player.walk:draw((player.x-view.x)*view.zoom + love.graphics.getWidth()/2, (player.y-view.y+0.1)*view.zoom+love.graphics.getHeight()/2, 0, player.direction * view.zoom/32, view.zoom/32, 34, 103)
  elseif player.falling and player.vy < 0 then
    love.graphics.draw(player.jump1, (player.x-view.x)*view.zoom + love.graphics.getWidth()/2, (player.y-view.y+0.1)*view.zoom+love.graphics.getHeight()/2, 0, player.direction * view.zoom/32, view.zoom/32, 34, 103)
  elseif player.falling then
    love.graphics.draw(player.jump2, (player.x-view.x)*view.zoom + love.graphics.getWidth()/2, (player.y-view.y+0.1)*view.zoom+love.graphics.getHeight()/2, 0, player.direction * view.zoom/32, view.zoom/32, 34, 103)
  elseif landTime > 0 then
    love.graphics.draw(player.land, (player.x-view.x)*view.zoom + love.graphics.getWidth()/2, (player.y-view.y+0.1)*view.zoom+love.graphics.getHeight()/2, 0, player.direction * view.zoom/32, view.zoom/32, 34, 103)
  else
    love.graphics.draw(player.stand, (player.x-view.x)*view.zoom + love.graphics.getWidth()/2, (player.y-view.y+0.1)*view.zoom+love.graphics.getHeight()/2, 0, player.direction * view.zoom/32, view.zoom/32, 34, 103)
  end
  
  -- Can't remember what this was for:
  --love.graphics.line((player.x-view.x)*view.zoom + love.graphics.getWidth()/2, (player.y-view.y-1.5)*view.zoom+love.graphics.getHeight()/2, (cursor.x-view.x)*view.zoom + love.graphics.getWidth()/2, (cursor.y-view.y)*view.zoom+love.graphics.getHeight()/2)
  
  love.graphics.setColor(0, 0, 0, cursorAlpha)
  if inreach then
    love.graphics.rectangle("line", (math.ceil(cursor.x)-1-view.x)*view.zoom + love.graphics.getWidth()/2, (math.ceil(cursor.y)-1-view.y)*view.zoom+love.graphics.getHeight()/2, view.zoom, view.zoom)
  end
  
  if mineProgress > 0 and mineProgress <= 1 then
    love.graphics.draw(breakImage[math.ceil(mineProgress * 8)], (mineBlock.c-1-view.x)*view.zoom + love.graphics.getWidth()/2, (mineBlock.r-1-view.y)*view.zoom+love.graphics.getHeight()/2, 0, view.zoom/16, view.zoom/16)
  end
  
  love.graphics.setColor(0, 0, 0, 127)
  if selected == 1 then love.graphics.setColor(0, 0, 0, 255) end
  love.graphics.print("Dirt: " .. player:checkInventory(DIRT), 50, 50)
  love.graphics.setColor(0, 0, 0, 127)
  if selected == 2 then love.graphics.setColor(0, 0, 0, 255) end
  love.graphics.print("Stone: " .. player:checkInventory(STONE), 50, 80)
  love.graphics.setColor(0, 0, 0, 127)
  if selected == 3 then love.graphics.setColor(0, 0, 0, 255) end
  love.graphics.print("Cobblestone: " .. player:checkInventory(COBBLESTONE), 50, 110)
  love.graphics.setColor(0, 0, 0, 127)
  if selected == 4 then love.graphics.setColor(0, 0, 0, 255) end
  love.graphics.print("Coal ore: " .. player:checkInventory(COAL_ORE), 50, 140)
  love.graphics.setColor(0, 0, 0, 127)
  if selected == 5 then love.graphics.setColor(0, 0, 0, 255) end
  love.graphics.print("Wood: " .. player:checkInventory(WOOD), 50, 170)
  
  if debug then
    love.graphics.setColor(0, 0, 0, 255)
    love.graphics.print(love.timer.getFPS() .. " fps", love.graphics.getWidth() - 150, 50)
  end
end



function love.keypressed(k, u)
  if k == "p" then
    showPerlin = not showPerlin
  elseif k == "escape" then
    generator:send("command", "quit")
    generator:wait()
    love.event.push("q")
  elseif k == "[" then
    if view.zoom > 1 then view.zoom = view.zoom / 2 end
  elseif k == "]" then
    if view.zoom < 256 then view.zoom = view.zoom * 2 end
  elseif k == "f3" then
    debug = not debug
  end
end



function love.keyreleased(k)

end



function love.mousepressed(x, y, button)
  if button == "wd" then
    selected = selected + 1
    if selected == 6 then selected = 1 end
  elseif button == "wu" then
    selected = selected - 1
    if selected == 0 then selected = 5 end
  end
end



function drawTerrain(terrain, zoom, x, y)
  local minR = math.max(terrain.rMin, math.floor((y - zoom * (love.graphics.getHeight() / 2)) / 32))
  local maxR = math.min(terrain.rMax, math.floor((y + zoom * (love.graphics.getHeight() / 2)) / 32))
  local minC = math.max(terrain.cMin, math.floor((x - zoom * (love.graphics.getWidth()  / 2)) / 32))
  local maxC = math.min(terrain.cMax, math.floor((x + zoom * (love.graphics.getWidth()  / 2)) / 32))
  love.graphics.setColor(255, 255, 255, 255)
  for r = minR, maxR do
    for c = minC, maxC do
      if terrain:hasChunk(r, c) then
        if terrain:getChunk(r, c).framebuffer == nil then terrain:getChunk(r, c):render() end
        love.graphics.draw(terrain:getChunk(r, c).framebuffer, (32*c-x)*zoom + love.graphics.getWidth()/2, (32*r-y)*zoom+love.graphics.getHeight()/2, 0, zoom/16, zoom/16)
      end
    end
  end
end



function drawTerrainPerlin(terrain, zoom, x, y)
  local minR = math.max(terrain.rMin, math.floor((y - zoom * (love.graphics.getHeight() / 2)) / 32))
  local maxR = math.min(terrain.rMax, math.floor((y + zoom * (love.graphics.getHeight() / 2)) / 32))
  local minC = math.max(terrain.cMin, math.floor((x - zoom * (love.graphics.getWidth()  / 2)) / 32))
  local maxC = math.min(terrain.cMax, math.floor((x + zoom * (love.graphics.getWidth()  / 2)) / 32))
  love.graphics.setColor(255, 255, 255, 255)
  for r = minR, maxR do
    for c = minC, maxC do
      if terrain:hasChunk(r, c) then
        if terrain:getChunk(r, c).framebufferPerlin == nil then terrain:getChunk(r, c):renderPerlin() end
        love.graphics.draw(terrain:getChunk(r, c).framebufferPerlin, (32*c-x)*zoom + love.graphics.getWidth()/2, (32*r-y)*zoom+love.graphics.getHeight()/2, 0, zoom/16, zoom/16)
      end
    end
  end
end



function pythag(x1, y1, x2, y2)
  if x2 == nil and y2 == nil then
    x2 = 0
    y2 = 0
  end
  return math.sqrt((x1-x2)^2 + (y1-y2)^2)
end

