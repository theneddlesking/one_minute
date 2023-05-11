
require_relative 'tilemap'

# a single screen level
class Level
    attr_accessor :tile_map, :mechanics, :map_data

    def initialize(map_data)
        @map_data = map_data
        @tile_map = TileMap.new(map_data)
        @mechanics = []
    end
end

# makes basic level with sky and ground
def generate_basic_map(width, height)
    ground_depth = 8

    # creates 2D array with given width and height
    map_data = Array.new(height) { Array.new(width, Tiles::SKY) }

    # creates a grass floor
    map_data[-ground_depth] = Array.new(width, Tiles::GRASS)

    # creates dirt below the grass
    (-(ground_depth-1)..-1).step(1) do |n|
        map_data[n] = Array.new(width, Tiles::DIRT)
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
    maps.puts(map_data.to_s)
    maps.close()
end