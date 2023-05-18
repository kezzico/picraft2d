local chunk_width = style.terrain.blocks_per_chunk
local chunk_height = style.terrain.blocks_per_chunk
local block_width = style.terrain.blocks_pixel_size
local block_height = style.terrain.blocks_pixel_size

function Chunk(p)
  return {
    r = p.r or 0,

    c = p.c or 0,

    front = { },

    back = { }
  }
end

function Block(i, j, x, y, type) 
  return { 
      type = type,

      x = x,

      y = y,

      i = i,

      j = j
    }
end

function generate_blocks(params, fn)
  local blocks = { }
  -- 1 block padding to include block in adjacent chunk
  for i=-1, chunk_width do
    for j=-1, chunk_height do
      local blockid = i..','..j

      local y = params.r*chunk_height+j

      local x = params.c*chunk_width+i

      local type = fn(x, y)

      if type ~= nil then 
        -- print(blockid..' '..y..' '..type.texture)
        blocks[blockid] = Block(i,j,x,y,type)
      end
    end
  end

  return blocks
end

function collision_barriers(blocks)
  local barriers = { }

  local w = style.terrain.blocks_pixel_size

  local h = style.terrain.blocks_pixel_size

  forEachPair(blocks, function(block)
    -- local block = blocks[xy]
    local chunk_width = style.terrain.blocks_per_chunk

    local chunk_height = style.terrain.blocks_per_chunk

    local i = block.i

    local j = block.j

    local x1 = i * w

    local y1 = j * h

    local x2 = x1 + w

    local y2 = y1 + h

    if i == -1 or i == chunk_width then return end
    if j == -1 or j == chunk_height then return end

    -- print(table_to_string(blocks))
    -- Top line
    if j >= 0 and blocks[(i)..','..(j-1)] == nil then
      -- print('here2: '..i..' '..j)

      local topLine = { {x1, y1}, {x2, y1} }
      table.insert(barriers, topLine)
    end

    -- Right line
    if i < chunk_width and blocks[(i+1)..','..(j)] == nil then
      local rightLine = { {x2, y1}, {x2, y2} }
      table.insert(barriers, rightLine)
    end

    -- Bottom line
    if j < chunk_height and blocks[(i)..','..(j+1)] == nil then    
      local bottomLine = { {x2, y2}, {x1, y2} }
      table.insert(barriers, bottomLine)
    end

    -- Left line
    if i >= 0 and blocks[(i-1)..','..(j)] == nil then
      local leftLine = { {x1, y2}, {x1, y1} }
      table.insert(barriers, leftLine)
    end
  end)

  return barriers
end