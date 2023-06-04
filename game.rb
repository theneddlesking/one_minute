require_relative 'level.rb'
require_relative 'character.rb'
require_relative 'collision.rb'
require_relative 'editor.rb'
require_relative 'timer.rb'
require_relative 'menu.rb'

require 'gosu'

EDITOR_MODE = false

class PlatformerGame < Gosu::Window
    WIDTH = 640
    HEIGHT = 480
    TILE_SIZE = 18
    CHARACTER_SIZE = 24

    attr_accessor :current_level, :player, :editor, :timer, :levels, :level_number, :level_count, :level_data, :characters, :menu
    
    def initialize
      super(WIDTH, HEIGHT)
      @level_data = [
        # Level 1 Data
        [
          # Decorations
          [],
          # Characters
          [Player.new(450, 50)],
          # Mechanics
          []
        ],
        # Level 2 Data
        [
          # Decorations
          [],
          # Characters
          [Player.new(200, 200)],
          # Mechanics
          []
        ],
        # Level 3 Data
        [
          # Decorations
          [],
          # Characters
          [],
          # Mechanics
          []
        ],
        # Level 4 Data
        [
          # Decorations
          [],
          # Characters
          [],
          # Mechanics
          []
        ],# Level 5 Data
        [
          # Decorations
          [],
          # Characters
          [],
          # Mechanics
          []
        ]
      ]

      @levels = create_levels(load_levels(2), @level_data)
      @level_number = 1
      @current_level = @levels[@level_number - 1]

      @level_count = @levels.length

      @menu = Menu.new()

      @timer = Timer.new()

      @editor = Editor.new([TileSet.new([Tiles::SKY, Tiles::DIRT, Tiles::GRASS, Tiles::FLAG], Gosu::KB_B)], @current_level)

      # load tiles from tile map image
      @tiles = Gosu::Image.load_tiles(self, "./images/tiles_packed.png", TILE_SIZE, TILE_SIZE, true)

      # load characters from image
      @character_tiles = Gosu::Image.load_tiles(self, "./images/characters_packed.png", CHARACTER_SIZE, CHARACTER_SIZE, true)

      # current characters to be rendered
      @characters = @current_level.characters

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
        if @menu.active
          # All menus just start a particular level, menu deactivates as the option has been selected
          menu.active = false
          start_level(@level_number, self)
        else
          jump(@current_level, @player)
        end
      end

      # If we are in the menu we don't want to do anything else
      if @menu.active
        return
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

      # If you run out of time then restart at level 1
      if @timer.done
        # Game restarts at level 1
        @level_number = 1
        game_lose(@menu)
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
      draw_background()

      draw_level(@current_level)

      # waiting menu choice
      if @menu.active
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

    def draw_background()
      sky = Gosu::Color.new(135, 206, 235)
      night = Gosu::Color.new(2, 7, 93)

      # draws sky background
      Gosu.draw_rect(0, 0, WIDTH, HEIGHT, sky, 0, mode = :default)
    end

    def draw_menu(menu)
      @menu.font.draw_text(@menu.message, 10, 200, 1)
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
  @menu.active = true
  @menu.message = "Level " + number.to_s + " Complete! Press [SPACE] for the next level"
end

def game_lose(menu)
  @menu.active = true
  @menu.message = "                 Game over! You ran out of time! \n                          Press [SPACE] to retry."

end

def game_win(menu)
  @menu.active = true
  @menu.message = "                   Congratulations! You win! \n If you want to play again, press [SPACE] to restart!"
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
