require_relative 'level.rb'
require_relative 'character.rb'
require_relative 'collision.rb'
require_relative 'editor.rb'
require_relative 'timer.rb'

require 'gosu'

EDITOR_MODE = false

class PlatformerGame < Gosu::Window
    WIDTH = 640
    HEIGHT = 480
    TILE_SIZE = 18
    CHARACTER_SIZE = 24

    attr_accessor :current_level, :player, :editor, :timer, :levels, :level_number, :level_count
    
    def initialize
      super(WIDTH, HEIGHT)
      @levels = load_levels(2)
      @level_number = 1
      @current_level = @levels[@level_number - 1]

      @level_count = @levels.length

      @timer = Timer.new()

      @editor = Editor.new([TileSet.new([Tiles::SKY, Tiles::DIRT, Tiles::GRASS, Tiles::FLAG], Gosu::KB_B)], @current_level)

      # load tiles from tile map image
      @tiles = Gosu::Image.load_tiles(self, "./images/tiles_packed.png", TILE_SIZE, TILE_SIZE, true)

      # load characters from image
      @character_tiles = Gosu::Image.load_tiles(self, "./images/characters_packed.png", CHARACTER_SIZE, CHARACTER_SIZE, true)

      # current characters to be rendered
      @characters = [Player.new()]

      # the player
      @player = @characters[0]
    end

    # this is called by Gosu to see if should show the cursor (or mouse)
    def needs_cursor?
      # only show cursor when editing
      # EDITOR_MODE
      return true
    end

    def update_game()
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
        apply_physics(@current_level, character)
      end

      if @player.beat_level || @player.x < 50
          level_complete(@level_number)

          # the player beat the final level so they beat the game
          if @level_number == @level_count 
            game_win()
          else # the player starts the next level
            start_level(@level_number + 1, self)
          end
      end 

      update_timer(@timer)

      # If you run out of time then restart at level 1
      if @timer.done
        game_lose()

        # TODO instead of instantly starting the next level take them back to the menu screen 
        start_level(1, self)
      end
    end

    def update
      if (EDITOR_MODE)
        update_editor(@editor)
      else
        update_game()
      end      
    end

    def draw
      draw_level(@current_level)

      # editor mode only needs tiles
      if !EDITOR_MODE
        draw_characters()

        draw_timer()
      end
    end

    def draw_timer()
      # draw timer in top left corner
      @timer.font.draw_text(@timer.seconds_left, 10, 10, 1)
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

    # draw tiles in level
    def draw_level(level)
      map_height = level.map_height
      map_width = level.map_width
      map_data = level.map_data
    
      map_height.times do |y|
        map_width.times do |x|

          # get tile index id
          tile_index = map_data[y][x].data.id
          next if tile_index == 0 # skip empty tiles

          # draw the tile image
          draw_tile(@tiles, tile_index, x * TILE_SIZE, y * TILE_SIZE)
        end
      end
    end
end

def level_complete(number)
  puts("Level " + number.to_s + " Complete!")
end

def game_lose()
  puts("Game over! You ran out of time!")
end

def game_win()
  puts("You win!")
end

# main game loop

def main
    # create game
    game = PlatformerGame.new

    # start first level
    start_level(1, game)    

    # render the game
    game.show
end

main
