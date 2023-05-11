# the tile codes from the image
# 20 tiles per row, indexed at 0
module Tiles
    SKY = 20 * 8 - 3
    DIRT = 20 * 6 + 3
    GRASS = 23
end

# a single tile
class Tile
    attr_accessor :id, :x, :y

    def initialize(id, x, y)
        @id = id
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
def fill_row(map_data, width, height, tile)
    map_data[height] = []
    width.times do |x|
        map_data[height] << Tile.new(tile, x, height)
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
        puts(dirt_row)
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
    tile_ids = map_data.map { |row| row.map { |cell| cell.id } }
    maps.puts(tile_ids.to_s)
    maps.close()
end