require 'gosu'

TILE_SIZE = 18
CHARACTER_SIZE = 24

def apply_physics(map_data, entity)
  # steps per frame, max of 1 to avoid going inside tiles
  step = 1

  # gravity
  entity.y_velocity += step

  y_step = step * sign(entity.y_velocity)

  if entity.y_velocity < 0
    puts(entity.y_velocity.to_s)
    puts(y_step.to_s)
    puts(entity.y.to_s)
  end

  
  entity.y_velocity.abs.times { 
    if !character_hit_tiles?(map_data, entity, 0, y_step) then 
      entity.y += y_step 
    else 
      if entity.y_velocity < 0
        puts("hit tile")
      end

      entity.y_velocity = 0 
    end 
  }
  
  # Directional walking, horizontal movement
  x_step = step * sign(entity.x_velocity)

  # Step in the direction of the entity's velocity until it hits a wall
  entity.x_velocity.abs.times { if !character_hit_tiles?(map_data, entity, x_step, 0) then entity.x += x_step end }

  # Velocity has been used up
  entity.x_velocity = 0

  

  # TODO: Check which tile was hit as it may have a special interaction eg. spike, ladder or button
end

def jump(map_data, player)
  # looks just at the feet of the player
  if solid?(map_data, player.x, player.y + 1)
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
    # Checks if tile is solid within
    collided = solid?(map_data, character.x + x_step, character.y + y_step) ||
    solid?(map_data, character.x + x_step - (CHARACTER_SIZE), character.y + y_step - (CHARACTER_SIZE))

    if collided
      # puts "collided x: " + character.x.to_s + " y: " + character.y.to_s
      # puts "velocity x: " + character.x_velocity.to_s + " y; " + character.y_velocity.to_s
    end

    return collided
end 

def solid?(map_data, x, y)
  x += CHARACTER_SIZE
  y += CHARACTER_SIZE
  return map_data[(y / TILE_SIZE)][(x / TILE_SIZE)].data.solid
end