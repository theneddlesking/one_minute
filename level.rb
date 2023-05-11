# data per tile type
class TileData
    attr_accessor :id, :solid

    def initialize(id, solid)
        @id = id
        @solid = solid
    end
end

# the tile codes from the image
# 20 tiles per row, indexed at 0
module Tiles
    SKY = TileData.new(20 * 8 - 3,  false)
    DIRT = TileData.new(20 * 6 + 3, true)
    GRASS = TileData.new(23, true)
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
def fill_row(map_data, width, height, data)
    map_data[height] = []
    width.times do |x|
        map_data[height] << Tile.new(data, x, height)
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

    map_data[height - ground_depth - 1][10] = Tile.new(Tiles::DIRT, 10, height - ground_depth + 1)

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