function Game()
  local seed = 0

  local terrain = nil

  local simulation = nil

  local seed_text = nil

  return {
    state = {
      view = { zoom = style.terrain.native_zoom_scale, x = 0, y = 0},

      active = false,
    },

    load = function(self, game_seed, generator_config)
      seed = math.random(65536) or game_seed

      print(seed)
      seed_text = Text("seed: "..seed, style.game.hub_text)

      generator = Generator(seed, generator_config or "generators/rolling-hills.lua")

      generator:start()

      terrain = Terrain(generator)
    end,

    suspend = function(self)

    end,

    draw = function(self)
      terrain:draw(self.state.view)

      seed_text:draw()
    end,

    update = function(self, dt)
      local view = self.state.view

      terrain:clean(view)
      terrain:generate(view)
    end,

    activate = function(self)
      self.state.active = true

      local delegate = ControllerDelegate()

      delegate.press_start = function()
        game:suspend()

        menu:activate()
      end

      delegate.press_left = function()
        self.state.view.x = self.state.view.x - 256 * self.state.view.zoom / style.terrain.native_zoom_scale
      end

      delegate.press_right = function()
        self.state.view.x = self.state.view.x + 256 * self.state.view.zoom / style.terrain.native_zoom_scale
      end

      delegate.press_up = function()
        self.state.view.y = self.state.view.y - 256 * self.state.view.zoom / style.terrain.native_zoom_scale
      end

      delegate.press_down = function()
        self.state.view.y = self.state.view.y + 256 * self.state.view.zoom / style.terrain.native_zoom_scale
      end

      delegate.press_function_1 = function()
        local toggle = not terrain.state.render_chunk_borders

        terrain.state.render_chunk_borders = toggle
      end

      delegate.press_function_2 = function()
        local toggle = not terrain.state.render_chunks

        terrain.state.render_chunks = toggle
      end

      delegate.press_number = function(n)
        self.state.view.zoom = style.terrain.native_zoom_scale/10 * (10-n)
      end

      controllers.player1.delegate = delegate

    end,

    suspend = function(self)

    end,
  }

end
