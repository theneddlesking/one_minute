# A way to make levels
class Editor
    SKY = 20
    DIRT = 40
    GRASS = 50

    def initialize()
        # automatically clears all map data
        reset_map_data()

        @map_data = generate_basic_map(35, 25)
    end

    def generate_basic_map(width, height)
        ground_depth = 4

        # creates 2D array with given width and height
        map_data = Array.new(height) { Array.new(width, SKY) }

        # creates a grass floor
        map_data[-ground_depth] = Array.new(width, GRASS)        

        # creates dirt below the grass
        map_data[1..2] = Array.new(width, DIRT)

        return map_data
    end


    # clears all map data
    def reset_map_data()
        maps = File.open("./maps.txt", "w") # open for writing
        maps.close()
    end

    # adds map data - persists
    def export_map_data()
        maps = File.open("./maps.txt", "a")
        maps.puts(@map_data.to_s)
        maps.close()
    end
end