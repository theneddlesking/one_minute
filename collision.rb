require 'gosu'

TILE_SIZE = 18
CHARACTER_SIZE = 24

def character_hit_tiles?(character, tiles)
    player_box = player.bounding_box
  
    tiles.each do |tile|
      tile_box = Gosu::Rectangle.new(tile.x, tile.y, TILE_SIZE, TILE_SIZE)
      
      if player_box.intersects?(tile_box)
        # Player has collided
        return true
      end
    end

    # Player has not collided
    return false
end 

def bounding_box(width, height)
    return Gosu::Rectangle.new(@x, @y, width, height)
end