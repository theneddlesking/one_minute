require 'json'

# data per tile type
class TileData
    attr_accessor :id, :solid, :collectable, :mechanic

    def initialize(id, solid, collectable, mechanic)
        @id = id
        @solid = solid
        @collectable = collectable
        @mechanic = mechanic
    end
end

module Mechanics
    NONE = :none
    FLAG = :flag
    SPIKE = :spike
    SPRING = :spring
    LADDER = :ladder
    LOCK = :lock
end

module Collectables
    NONE = :none
    KEY = :key
    COIN = :coin
    DIAMOND = :diamond
end

$tile_map = {}

def add_new_tile_data(id, solid = true, collectable = Collectables::NONE, mechanic = Mechanics::NONE)
    tile_data = TileData.new(id, solid, collectable, mechanic)
    $tile_map.store(id, tile_data)
    return tile_data
end

# the tile codes from the image
# 20 tiles per row, indexed at 0
module Tiles
    # Blocks
    SKY = add_new_tile_data(0,  false)
    DIRT = add_new_tile_data(20 * 6 + 3)
    GRASS = add_new_tile_data(23)

    # false, Collectables
    COIN = add_new_tile_data(20 * 7 + 12, false, Collectables::COIN)
    DIAMOND = add_new_tile_data(20 * 3 + 8, false, Collectables::DIAMOND)
    KEY = add_new_tile_data(20 + 8, false, Collectables::KEY)

    # Tiles with mechanics
    FLAG1 = add_new_tile_data(20 * 5 + 12, false, Collectables::NONE, Mechanics::FLAG)
    FLAG2 = add_new_tile_data(20 * 6 + 12, false, Collectables::NONE, Mechanics::FLAG)

    LADDER1 = add_new_tile_data(20 * 2 + 12, false, Collectables::NONE, Mechanics::LADDER)
    LADDER2 = add_new_tile_data(20 * 3 + 12, false, Collectables::NONE, Mechanics::LADDER)

    SPIKE = add_new_tile_data(20 * 3 + 9, false, Collectables::NONE, Mechanics::SPIKE)
    LOCK = add_new_tile_data(20 + 9, false, Collectables::NONE, Mechanics::LOCK)
    SPRING = add_new_tile_data(20 * 5 + 9, false, Collectables::NONE, Mechanics::SPRING)
end

# a single tile
class Tile
    attr_accessor :data, :x, :y, :collected

    def initialize(data, x, y)
        @data = data
        @x = x
        @y = y

        # used for collectables
        @collected = false
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
    attr_accessor :map_data, :map_height, :map_width, :characters

    def initialize(map_data)
        @map_data = map_data
        @map_height = map_data.length
        @map_width = map_data[0].length
    
        @characters = characters
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

def load_level_maps(count)
    maps = File.open("./maps.txt", "r")
    levels = []

    count.times {
        str = maps.gets.to_s

        # no more maps to read
        if (str == '')
            break
        end

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


def start_level(level_number, game)
    game.level_number = level_number
    game.current_level = game.levels[game.level_number - 1]
  
    setup_level(game.current_level)

    # load current player and characters for that level into the game
    game.player = game.current_level.characters[0]
    game.characters = game.current_level.characters
  
    # the timer begins again
    reset_timer(game.timer)

    start_timer(game.timer)
end

def add_characters_to_levels(levels, level_data)
    levels.each_with_index do | level, index |
        characters = level_data[index]
        add_characters(level, characters)
    end
end

def add_characters(level, characters)
    level.characters = characters
end

def setup_level(level)
    player = level.characters[0]

    # set characters
    level.characters.each do |character|
      # reset physics and positions of all characters
      reset_entity(character)

      # TODO reset enemy pathing?
    end

    reset_collectables(level, player)
    
    player.beat_level = false
    player.has_key = false
    player.coins = 0
    player.diamonds = 0
end

def reset_collectables(level, player)
    level.map_data.each do |row| 
        row.each do |tile|  
            # if the tile is a collectable (eg. coin, diamond) that has been collected
            
            if (tile.data.collectable != Collectables::NONE)
                # add back the collectable to recollect and remove it from the playe3r
                if tile.collected
                    # the player loses all their collectables per death
                    case tile.data.collectable
                    when Collectables::DIAMOND
                      player.diamonds -= 1
                    when Collectables::COIN
                      player.coins -= 1
                    end        

                    # can be collected again
                    tile.collected = false
                end
            end
        end    
    end
end

def reset_entity(entity)
    entity.x = entity.start_x
    entity.y = entity.start_y
    entity.x_velocity = 0
    entity.x_velocity = 0
end
