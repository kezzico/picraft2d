function Game()
  local seed = 0

  local terrain = nil

  local simulation = nil

  local seed_text = nil

  return {
    state = {
      player = Entity(style.entities.black_coffee),
      
      active = false,

      view = { 
        zoom = style.terrain.native_zoom_scale/10 * (10-7), 
        x = 0, y = 0,
        screen_width = 1, screen_height = 1
      }
    },

    load = function(self, game_seed, generator_config)
      seed = math.random(65536) or game_seed

      seed_text = Text("seed: "..seed, style.game.hub_text)

      generator = Generator(seed, generator_config or "generators/checkers.lua")

      generator:start()

      terrain = Terrain(generator)

      simulation = Simulation()

      self.state.player.state.position = Vector.new(9900, 1200)
      table.insert(simulation.state.entities, self.state.player)
    end,

    suspend = function(self)

    end,

    draw = function(self)
      terrain:draw(self.state.view)
      simulation:draw(self.state.view)
      seed_text:draw()
    end,

    update = function(self, dt)
      local view = self.state.view
      view.screen_width = global_state.screen_width
      view.screen_height = global_state.screen_height

      local player = self.state.player
      local p1cs = controllers[1].state

      if player ~= nil then
        if self.state.active then
          view.x = player.state.position.x * view.zoom / style.terrain.native_zoom_scale
          view.y = player.state.position.y * view.zoom / style.terrain.native_zoom_scale
        end

        local walk_speed = 10.0

        if p1cs.run > 0.0 then
          walk_speed = 15.0
        end

        if p1cs.left > 0.0 then
          player.state.velocity.x = player.state.velocity.x - p1cs.left * walk_speed
        end

        if p1cs.right > 0.0 then
          player.state.velocity.x = player.state.velocity.x + p1cs.right * walk_speed
        end
      end

      terrain:clean(view)
      terrain:generate(view)

      simulation:clean()
      simulation:update(dt,terrain.state.chunks)
    end,

    activate = function(self)
      self.state.active = true

      local delegate = ControllerDelegate()

      delegate.press_start = function()
        game:suspend()

        menu:activate()
      end

      -- delegate.press_left = function()
      --   if player.state.velocity.x > -1000 then
      --     player.state.velocity.x = entity.state.velocity.x - 100
      --   end
      -- end

      -- delegate.press_right = function()
      --   if entity.state.velocity.x < 1000 then
      --     entity.state.velocity.x = entity.state.velocity.x + 100
      --   end
      -- end

      -- delegate.press_up = function()
      --   if entity.state.velocity.y > -1000 then
      --     entity.state.velocity.y = entity.state.velocity.y - 100
      --   end
      -- end

      -- delegate.press_down = function()
      --   if entity.state.velocity.y < 1000 then
      --     entity.state.velocity.y = entity.state.velocity.y + 100
      --   end
      -- end

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

      controllers[1].delegate = delegate

    end,

    suspend = function(self)
      self.state.active = false
    end,
  }

end
