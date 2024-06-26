require_relative 'level.rb'
require_relative 'character.rb'
require_relative 'collision.rb'
require_relative 'editor.rb'
require_relative 'timer.rb'
require_relative 'menu.rb'
require 'gosu'

class PlatformerGame < Gosu::Window
    WIDTH = 640
    HEIGHT = 480
    TILE_SIZE = 18
    CHARACTER_SIZE = 24

    EDITOR_MODE = false


    attr_accessor :current_level, :player, :editor, :timer, :levels, :level_number, :level_count, :characters, :menu, :character_data, :editor, :started
    
    def initialize
      super(WIDTH, HEIGHT)
      @character_data = [
        [
          # Level 1 Characters
          Player.new(550, 50)
        ],
        [
          # Level 2 Characters
          Player.new(600, 370)
        ],
        [
          # Level 3 Characters
          Player.new(600, 240)
        ],
        [
          # Level 4 Characters
          Player.new(430, 50)
        ],
        [
          # Level 5 Characters
          Player.new(50, 370)
        ]
      ]

      # has the game started yet or still on main menu
      @started = false

      @levels = add_characters_to_levels(load_level_maps(5), @character_data)

      @level_number = 1
      @current_level = @levels[@level_number - 1]

      @editor = Editor.new(@current_level)

      @level_count = @levels.length

      @menu = Menu.new()

      @timer = Timer.new()

      # load tiles from tile map image
      @tiles = Gosu::Image.load_tiles(self, "./images/tiles_packed.png", TILE_SIZE, TILE_SIZE, true)

      # load characters from image
      @character_tiles = Gosu::Image.load_tiles(self, "./images/characters_packed.png", CHARACTER_SIZE, CHARACTER_SIZE, true)

      # current characters to be rendered
      @characters = @current_level.characters

      # the player
      @player = @characters[0]

      if (EDITOR_MODE)
        # display message to let user know the program is in edit mode
        draw_editor_text(@menu)
        # clear all other maps
        reset_map_data()
      end
  
    end


    # this is called by Gosu to see if should show the cursor (or mouse)
    def needs_cursor?
      # only show cursor when editing
      return EDITOR_MODE
    end

    def update_game()
      # if game hasn't started yet don't read the game loop yet
      if !@started
        draw_main_menu(@menu)
      end

      if @menu.active
        if button_down?(Gosu::KB_RETURN)
          # All menus just start a particular level, menu deactivates as the option has been selected
          menu.active = false
          @started = true

          # All menu text now displays at the bottom of the screen
          menu.x = 10
          menu.y = 425

          # Start the next level
          start_level(@level_number, self)
        end        
        return
      end

      # Jump
      if button_down?(Gosu::KB_SPACE)
        jump(@current_level, @player)
      end

      # Move Left
      if button_down?(Gosu::KbLeft)
        @player.x_velocity = -5
      end

      # Move Right
      if button_down?(Gosu::KbRight)
        @player.x_velocity = 5
      end

      # Make airborne characters fall
      @characters.each do |character| 
        # apply x and y velocities to all characters
        apply_physics(@current_level, @player, character)
      end

      # Check if player should interact with tile with special mechanic (eg. spike, coin, diamond)

      # check which tile was hit as it may have a special interaction eg. spike, ladder, coin etc.
      tile = get_current_tile(@current_level, @player.x, @player.y)

      # use the mechanic of the tile
      activate_tile(@player, tile, @current_level)

      if @player.beat_level

          # the player beat the final level so they beat the game
          if @level_number == @level_count 
            reset_timer(@timer)
            
            # next time you play it starts at level 1
            @level_number = 1
            game_win(@menu)
          else # the player starts the next level
            reset_timer(@timer)
            level_complete(@level_number)

            @level_number += 1
          end
      end 

      update_timer(@timer)

      # if you fell off the map or died to enemy / spike
      if @player.y > HEIGHT || @player.dead
        # respawn player
        @player.dead = false
        @player.has_key = false
        reset_collectables(@current_level, @player)
        reset_entity(@player)
      end


      # If you run out of time then restart at level 1
      if @timer.done || @player.y > HEIGHT 
        # Game restarts at level 1
        @level_number = 1
        game_lose(@menu)
      end
    end

    def update
      if (button_down?(Gosu::KB_ESCAPE))
        # automatically saves last level
        if (EDITOR_MODE)
          export_map_data(editor.level.map_data)
        end
        close()
      end

      if (EDITOR_MODE)
        update_editor(@editor)
      else
        update_game()
      end      
    end

    def draw
      draw_background()

      if @started || EDITOR_MODE
        draw_level(@current_level)
      end

      # waiting menu choice
      if @menu.active || EDITOR_MODE
        draw_menu(@menu)
      end

      # editor mode only needs tiles
      if !EDITOR_MODE && @timer.running
        draw_characters()

        draw_timer()
      end
    end

    def draw_timer()
      # draw timer in top left corner
      @timer.font.draw_text("Level " + @level_number.to_s + "     Time Left: " + @timer.seconds_left.to_s + "     Coins: " + @player.coins.to_s , 10, 425, 1)
    end

    # draw characters on top of the existing level
    def draw_characters()
      @characters.each { |character| draw_tile(@character_tiles, character.id, character.x, character.y) }
    end

    # draw a single tile image at some coordinates
    def draw_tile(tiles, index, x, y)
      tile_x = (index - 1) % (tiles.size / TILE_SIZE)
      tile_y = (index - 1) / (tiles.size / TILE_SIZE)

      tiles[tile_x + tile_y * (tiles.size / TILE_SIZE)].draw(x, y, 0)
    end 

    def draw_background()
      sky = Gosu::Color.new(135, 206, 235)
      night = Gosu::Color.new(2, 7, 93)

      # draws sky background
      Gosu.draw_rect(0, 0, WIDTH, HEIGHT, sky, 0, mode = :default)
    end

    def draw_menu(menu)
      # draws menu text at the bottom of the screen
      @menu.font.draw_text(@menu.message, @menu.x, @menu.y, 1, 1, 1, Gosu::Color::BLACK)
    end

    # draw tiles in level
    def draw_level(level)
      map_height = level.map_height
      map_width = level.map_width
      map_data = level.map_data
    
      map_height.times do |y|
        map_width.times do |x|
          tile = map_data[y][x]

          # get tile index id
          tile_index = tile.data.id
          next if tile_index == 0 # skip empty tiles
          next if tile.collected
          next if @player.has_key && tile.data.mechanic == Mechanics::LOCK

          # draw the tile image
          draw_tile(@tiles, tile_index, x * TILE_SIZE, y * TILE_SIZE)
        end
      end
    end
end

# activate collectable / mechanic associated with the tile
def activate_tile(player, tile, level)
  if tile == nil
    return
  end

  # Collect collectable
  if (!tile.collected)
    case tile.data.collectable
    when Collectables::KEY
      player.has_key = true
      remove_collectable(level, tile)
    when Collectables::DIAMOND
      player.diamonds += 1
      remove_collectable(level, tile)
    when Collectables::COIN
      player.coins += 1
      remove_collectable(level, tile)
    end
  end

  # Activate special tile mechanic
  case tile.data.mechanic
  when Mechanics::SPIKE
    player.dead = true
  when Mechanics::FLAG
    player.beat_level = true
  when Mechanics::SPRING
    player.y_velocity = -20 
  when Mechanics::LADDER
    player.y_velocity = -5
  end
end

def remove_collectable(level, collectable)
  collectable.collected = true
end


# main game loop
def main
    # create game
    game = PlatformerGame.new

    # render the game
    game.show
end

main
