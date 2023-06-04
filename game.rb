require_relative 'level.rb'
require_relative 'character.rb'
require_relative 'collision.rb'
require_relative 'editor.rb'

require 'gosu'


EDITOR_MODE = false

class PlatformerGame < Gosu::Window
    WIDTH = 640
    HEIGHT = 480
    TILE_SIZE = 18
    CHARACTER_SIZE = 24

    attr_accessor :current_level, :player, :editor 
    
    def initialize
      super(WIDTH, HEIGHT)
      @levels = load_levels(1)
      @level_number = 1
      @current_level = @levels[@level_number - 1]


      @editor = Editor.new([TileSet.new([Tiles::SKY, Tiles::DIRT, Tiles::GRASS], Gosu::KB_B)], @current_level)

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
      end
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

# main game loop

def main
    # create game
    game = PlatformerGame.new

    # start first level
    start_level(game.current_level)    

    # render the game
    game.show
end

def start_level(level)
    reset_map_data()

    # temporary export so that progress isn't lost
    export_map_data(level.map_data)
end

main
