require 'gosu'

TILE_SIZE = 18
CHARACTER_SIZE = 24

def apply_physics(entity)
  # gravity
  entity.y_velocity += 0.2
  entity.y_velocity = [entity.y_velocity, entity.max_y_velocity].min()

  #friction
  friction = 0.1
  # calculate the direction of the player's velocity
  if player.x_velocity > 0
    direction = -1  
  elsif player.x_velocity < 0
    direction = 1
  else
    direction = 0  # no friction if the player isn't moving
  end

  entity.x_velocity += friction * direction

  # stops the friction once the character is stopped
  if sign(entity.x_velocity) == direction
      entity.x_velocity = 0
  end


  entity.x_velocity = [entity.x_velocity.abs(), entity.max_x_velocity].min() * sign(entity.x_velocity)

  entity.x += entity.x_velocity
  entity.y += entity.y_velocity
end

# get the sign
def sign(x)
  if (x > 0) 
    return 1
  end
  if (x < 0) 
    return -1
  end
  return 0
end

def character_hit_tiles?(character, tiles)
    character_box = BoundingBox.new(CHARACTER_SIZE, CHARACTER_SIZE, character.x, character.y)
    tiles.each do |tile|
      # skip tiles you can't collide with
      if !tile.data.solid 
        next
      end

      # get the collision box of the current tile
      tile_box = BoundingBox.new(TILE_SIZE, TILE_SIZE, tile.x * TILE_SIZE, tile.y * TILE_SIZE)
      
      if boxes_overlap?(character_box, tile_box)
        # Player has collided

         # Undo the overlap
        handle_tile_collision(character_box, tile_box, character)

        return true
      end
    end

    # Player has not collided
    return false
end 

class BoundingBox
  attr_accessor :x1, :y1, :x2, :y2, :x3, :y3, :x4, :y4, :width, :height

  def initialize(width, height, x1, y1)
    @x1 = x1
    @y1 = y1
    @x2 = x1 + width
    @y2 = y1
    @x3 = x1 + width
    @y3 = y1 + height
    @x4 = x1
    @y4 = y1 + height
    @width = width
    @height = height
  end
end


def handle_tile_collision(box1, box2, entity)
  overlap_x = [box1.x1 + box1.width - box2.x1, box2.x1 + box2.width - box1.x1].min
  overlap_y = [box1.y1 + box1.height - box2.y1, box2.y1 + box2.height - box1.y1].min

  puts(overlap_x)
  puts(overlap_y)

  # determine if the player is colliding from the top or bottom of the tile
  if overlap_x > overlap_y
    if box1.x1 < box2.x1
        entity.x -= overlap_x
    else
        entity.x += overlap_x
    end
  else
    if box1.y1 < box2.y1
        entity.y -= overlap_y
    else
        entity.y += overlap_y
    end
end
end



def boxes_overlap?(box1, box2)
  # Check if any of box1's corners are inside box2
  if point_inside_box?(box1.x1, box1.y1, box2) ||
     point_inside_box?(box1.x2, box1.y2, box2) ||
     point_inside_box?(box1.x3, box1.y3, box2) ||
     point_inside_box?(box1.x4, box1.y4, box2)
    return true
  end

  # Check if any of box2's corners are inside box1
  if point_inside_box?(box2.x1, box2.y1, box1) ||
     point_inside_box?(box2.x2, box2.y2, box1) ||
     point_inside_box?(box2.x3, box2.y3, box1) ||
     point_inside_box?(box2.x4, box2.y4, box1)
    return true
  end

  # If none of the corners are inside the other box, the boxes don't overlap
  return false
end

def point_inside_box?(x, y, box)
  if x >= box.x1 && x <= box.x3 && y >= box.y1 && y <= box.y3
    return true
  else
    return false
  end
end