require 'json'

# data per tile type
class TileData
    attr_accessor :id, :solid

    def initialize(id, solid)
        @id = id
        @solid = solid
    end
end

$tile_map = {}

def add_new_tile_data(id, solid = true)
    tile_data = TileData.new(id, solid)
    $tile_map.store(id, tile_data)
    return tile_data
end
    

# the tile codes from the image
# 20 tiles per row, indexed at 0
module Tiles
    SKY = add_new_tile_data(0,  false)
    DIRT = add_new_tile_data(20 * 6 + 3)
    GRASS = add_new_tile_data(23)
end


# a single tile
class Tile
    attr_accessor :data, :x, :y

    def initialize(data, x, y)
        @data = data
        @x = x
        @y = y
    end
end

class TileSet
    attr_accessor :tiles, :current_index, :tile, :shortcut, :current_tile, :tile_count, :key_pressed

    def initialize(tiles, shortcut)
        @tiles = tiles
        @tile_count = tiles.length
        @current_index = 0
        @shortcut = shortcut
        @current_tile = tiles[0]
        @key_pressed = false
    end
end

# a single screen level
class Level
    attr_accessor :tile_map, :mechanics, :map_data, :map_height, :map_width

    def initialize(map_data)
        @map_data = map_data
        @map_height = map_data.length
        @map_width = map_data[0].length
    
        @mechanics = []
    end
end

# fills a row at some indexed height with a paritcular tile
def fill_row(map_data, width, height, data, length = nil)
    if (length == nil)
        length = width
    end
    
    map_data[height] = []
    width.times do |x|
        if x > length
            map_data[height] << Tile.new(Tiles::SKY, x, height)
        else
            map_data[height] << Tile.new(data, x, height)
        end
    end
end

# makes basic level with sky and ground
def generate_basic_map(width, height)
    ground_depth = 5

    # creates 2D array with given width and height filled with sky tiles as the background
    map_data = []

    height.times do |y|
        row = []
        width.times do |x|
            row << Tile.new(Tiles::SKY, x, y)
        end
        map_data << row
    end

    # creates a grass floor
    fill_row(map_data, width, height - ground_depth, Tiles::GRASS)

    # creates dirt below the grass
    (1..(ground_depth-1)).step(1) do |dirt_row|
        fill_row(map_data, width, height - dirt_row, Tiles::DIRT)
    end

    return map_data
end

# clears all map data
def reset_map_data()
    maps = File.open("./maps.txt", "w") # open for writing
    maps.close()
end

# adds map data - persists
def export_map_data(map_data)
    maps = File.open("./maps.txt", "a")
    # just get the id of each tile 
    tile_ids = map_data.map { |row| row.map { |cell| cell.data.id } }
    maps.puts(tile_ids.to_s)
    maps.close()
end

def load_levels(count)
    maps = File.open("./maps.txt", "r")
    levels = []

    count.times {
        str = maps.gets.to_s
        map = JSON.parse(str)

        # convert ids back to the actual map data
        tiles = []
        map.each_with_index do |row, y|
          tile_row = []
          row.each_with_index do |tile_id, x|
            tile_row << Tile.new($tile_map[tile_id], x, y)
          end
          tiles << tile_row
        end

        level = Level.new(tiles)
        levels << level
    }

    maps.close()

    return levels
end