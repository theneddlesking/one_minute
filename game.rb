require_relative 'tilemap.rb'
require_relative 'editor.rb'

require 'gosu'

class PlatformerGame < Gosu::Window
    WIDTH = 640
    HEIGHT = 480
    TILE_SIZE = 18

    attr_accessor :current_level
    
    def initialize
      super(WIDTH, HEIGHT)
      @levels = [Level.new(generate_basic_map(36, 27))]
      @level_number = 1
      @current_level = @levels[@level_number - 1]

      # load tiles from tile map image
      @tiles = Gosu::Image.load_tiles(self, "./images/tiles_packed.png", TILE_SIZE, TILE_SIZE, true)
    end

    def draw
      draw_level(@current_level)
    end

    def draw_level(level)
      tile_map = level.tile_map

      map_height = tile_map.map_height
      map_width = tile_map.map_width
      map_data = tile_map.map_data

      map_height.times do |y|
        map_width.times do |x|
          tile_index = map_data[y][x]
          next if tile_index == 0 # skip empty tiles

          # get the x and y coordinates of the image in the tile set image
          tile_x = (tile_index - 1) % (@tiles.size / TILE_SIZE)
          tile_y = (tile_index - 1) / (@tiles.size / TILE_SIZE)

          # draw the image
          @tiles[tile_x + tile_y * (@tiles.size / TILE_SIZE)].draw(x * TILE_SIZE, y * TILE_SIZE, 0)
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
    # temporary export so that progress isn't lost
    export_map_data(level.map_data)
end

main
