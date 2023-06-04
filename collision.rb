require 'gosu'

TILE_SIZE = 18
CHARACTER_SIZE = 24

def apply_physics(map_data, entity)
  # steps per frame, max of 1 to avoid going inside tiles
  step = 1

  # Directional walking, horizontal movement
  x_step = step * sign(entity.x_velocity)

  # Step in the direction of the entity's velocity until it hits a wall
  entity.x_velocity.abs.times { if character_hit_tiles?(map_data, entity, x_step, 0) then entity.x += x_step end }

  # Velocity has been used up
  entity.x_velocity = 0

  puts(entity.y_velocity.to_s)

  # gravity
  entity.y_velocity += step
  
  y_step = step * sign(entity.y_velocity)

  entity.y_velocity.abs.times { if character_hit_tiles?(map_data, entity, 0, y_step) then entity.y += step else entity.y_velocity = 0 end }
  

  # TODO: Check which tile was hit as it may have a special interaction eg. spike, ladder or button
end

def jump(map_data, player)
  # looks just at the feet of the player
  if solid?(map_data, player.x, player.y + 1)
    puts("Jump")
    player.y_velocity = -20
  end
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

def character_hit_tiles?(map_data, character, x_step, y_step)
    # Checks if tile is solid within the two diagonally adjacent tiles in that horizontal direction
    collided = !solid?(map_data, character.x + x_step, character.y + y_step) &&
    !solid?(map_data, character.x + x_step, character.y + y_step - (0))

    if collided
      puts "collided x: " + character.x.to_s + " y: " + character.y.to_s
    end

    return collided
end 

def solid?(map_data, x, y)
  
  return map_data[(y / TILE_SIZE) + 1][(x / TILE_SIZE) + 1].data.solid
end