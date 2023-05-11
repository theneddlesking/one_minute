require_relative 'level.rb'
require_relative 'character.rb'
require 'gosu'


class PlatformerGame < Gosu::Window
    WIDTH = 640
    HEIGHT = 480
    TILE_SIZE = 18
    CHARACTER_SIZE = 24

    attr_accessor :current_level
    
    def initialize
      super(WIDTH, HEIGHT)
      @levels = [Level.new(generate_basic_map(36, 27))]
      @level_number = 1
      @current_level = @levels[@level_number - 1]

      # load tiles from tile map image
      @tiles = Gosu::Image.load_tiles(self, "./images/tiles_packed.png", TILE_SIZE, TILE_SIZE, true)

      # load characters from image
      @character_tiles = Gosu::Image.load_tiles(self, "./images/characters_packed.png", CHARACTER_SIZE, CHARACTER_SIZE, true)

      # current characters to be rendered
      @characters = [Player.new()]
    end

    def draw
      draw_level(@current_level)
      draw_characters()
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
          tile_index = map_data[y][x].id
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
