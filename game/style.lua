style = {
  menu = {
    background_color = {r=0,g=0,b=0.5,a=0.5},

    music = "music/DR0000_0401.mp3",

    button = {
      width = 200,

      height = 64,

      background_color_highlight = {255, 0, 0},

      text_color_highlight = {255, 255, 255},

      background_color = {255, 255, 255},

      text_color = {255, 0, 0},

      -- font = love.graphics.newFont("fonts/joystix.ttf", 25),
      fontname = { "fonts/joystix.ttf", 25 },
    }
  },

  game = {
    hub_text = {
      text_color = {1,1,0,1},

      fontname = { "fonts/joystix.ttf", 25 }
    }
  },

  terrain = {
    chunk = {
      border_color = {255,255,0,0.5},

      text_color = {255, 255, 255,1.0},

      text_shadow_color = {0, 0, 0, 1.0},

      -- font = love.graphics.newFont("fonts/joystix.ttf", 64),
      fontname = { "fonts/joystix.ttf", 64 },
    },

    blocks = {
      bricks_overworld = { 
        texture = 'textures/bricks_overworld.png' 
      },
      bricks_underworld = { 
        texture = 'textures/bricks_underworld.png' 
      },
      groundy_overworld = { 
        texture = 'textures/groundy_overworld.png' 
      },
      groundy_underworld = { 
        texture = 'textures/groundy_underworld.png' 
      },
      hardblock_overworld = {
          texture = 'textures/hardblock_overworld.png'
      },
      hardblock_underworld = {
          texture = 'textures/hardblock_underworld.png'
      },      
      dark = {
          texture = 'textures/dark.png'
      },      
    },

    native_zoom_scale = 16,

    blocks_pixel_size = 15*6,

    blocks_per_chunk = 4,

  },

  entities = {
    black_coffee = {
      imagepath = "sprites/mocha.png",

      frame_width = 15, frame_height = 15,

      animations = {
        stand = { 1 },
        jump = { 2 },
        stop = { 3 },
        run = { 4,5,6 }
      }
    }
  }

}

biomes = {
  overworld = {
    bricks = style.terrain.blocks.bricks_overworld,
    groundy = style.terrain.blocks.groundy_overworld,
    hardblock = style.terrain.blocks.hardblock_overworld,
    background = { 
      style.terrain.blocks.bricks_overworld 
    }
  },

  underworld = {
    bricks = style.terrain.blocks.bricks_underworld,
    groundy = style.terrain.blocks.groundy_underworld,
    hardblock = style.terrain.blocks.hardblock_underworld,
    background = { 
      style.terrain.blocks.dark,
      style.terrain.blocks.bricks_underworld
    }
  }
}
