require 'gosu'

class TileMap
  TILE_SIZE = 18
  
  def initialize(window, map_data)
    @window = window

    @map_data = map_data
    @map_width = @map_data[0].length
    @map_height = @map_data.length

    puts(@map_width.to_s + " " + @map_height.to_s  )

    @tiles = Gosu::Image.load_tiles(@window, "./images/tiles_packed.png", TILE_SIZE, TILE_SIZE, true)
  end

  def update_map_data(map_data)
    @map_data = map_data
    @map_width = @map_data[0].length
    @map_height = @map_data.length
  end
  
  def draw
    @map_height.times do |y|
      @map_width.times do |x|
        tile_index = @map_data[y][x]
        next if tile_index == 0 # skip empty tiles
        tile_x = (tile_index - 1) % (@tiles.size / TILE_SIZE)
        tile_y = (tile_index - 1) / (@tiles.size / TILE_SIZE)
        @tiles[tile_x + tile_y * (@tiles.size / TILE_SIZE)].draw(x * TILE_SIZE, y * TILE_SIZE, 0)
      end
    end
  end
end