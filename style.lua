style = {
  menu = {
    background_color = {r=0,g=0,b=88,a=0.5},

    music = "music/DR0000_0401.mp3",

    button = {
      width = 200,

      height = 64,

      background_color_highlight = {255, 0, 0},

      text_color_highlight = {255, 255, 255},

      background_color = {255, 255, 255},

      text_color = {255, 0, 0},

      font = love.graphics.newFont("fonts/joystix.ttf", 25),
    }
  },

  terrain = {
    chunk = {
      border_color = {255,255,0,0.5},

      text_color = {255, 255, 255,1.0},

      text_shadow_color = {0, 0, 0, 1.0},

      font = love.graphics.newFont("fonts/joystix.ttf", 64),
    },

    native_zoom_scale = 16,

    blocks_pixel_size = 16,

    blocks_per_chunk = 32,

  }
}
