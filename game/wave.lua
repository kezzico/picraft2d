local function lerp(a, b, t)
  return a + t * (b - a)
end

local function smoothstep(x)
  return 3 * x^2 - 2 * x^3
end

function wave(seed, x, freq, amp)
  local block_width = style.terrain.blocks_per_chunk
  -- local p0 = math.floor(params.c / freq) * freq
  local c  = x / block_width
  local p0 = math.floor(c / freq) * freq
  local p1 = p0 + freq
  local px = ((c) - p0) / freq

  local h0 = random(seed, p0..'') * amp
  local h1 = random(seed, p1..'') * amp

  local wave = lerp(h0, h1, px)

  return wave
end

