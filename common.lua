-- Modes
MENU = 1
GENERATING = 2
PLAY = 3

-- Block codes
AIR = 0
STONE = 1
DIRT = 3
COBBLESTONE = 4
COAL_ORE = 16
UNGENERATED = 255

durability = {}
durability[STONE] = 2
durability[DIRT] = 1
durability[COBBLESTONE] = 2
durability[COAL_ORE] = 3

breakGive = {}
breakGive[STONE] = COBBLESTONE
breakGive[DIRT] = DIRT
breakGive[COBBLESTONE] = COBBLESTONE
breakGive[COAL_ORE] = COAL_ORE

-- Random number engine
rand = {mySeed = 1, lastN = -1}
function rand:get(seed, n)
  if n <= 0 then n = -2 * n
  else n = 2 * n - 1
  end
  
  if seed ~= self.mySeed or self.lastN < 0 or n <= self.lastN then
    self.mySeed = seed
    math.randomseed(seed)
    self.lastN = -1
  end
  while self.lastN < n do
    num = math.random()
    self.lastN = self.lastN + 1
  end
  return num - 0.5
end