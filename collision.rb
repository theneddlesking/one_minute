TILE_SIZE = 18
CHARACTER_SIZE = 24

def apply_physics(level, entity)
  # steps per frame, max of 1 to avoid going inside tiles
  step = 1

  # gravity
  entity.y_velocity += step

  y_step = step * sign(entity.y_velocity)
  
  entity.y_velocity.abs.times { if !character_hit_tiles?(level, entity, 0, y_step) then entity.y += y_step else entity.y_velocity = 0 end }
  
  # Directional walking, horizontal movement
  x_step = step * sign(entity.x_velocity)

  # Step in the direction of the entity's velocity until it hits a wall
  entity.x_velocity.abs.times { if !character_hit_tiles?(level, entity, x_step, 0) then entity.x += x_step end }

  # Velocity has been used up
  entity.x_velocity = 0

  # TODO: Check which tile was hit as it may have a special interaction eg. spike, ladder or button

  # TODO: Check if player has fallen off the map
end

def jump(level, player)
  # looks just at the feet of the player
  if solid?(level, player.x, player.y + 1)
    player.y_velocity = -@player.jump_height
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

def character_hit_tiles?(level, character, x_step, y_step)
    # Character is smaller than a single block so you need to check the block directly below

    # Checks if tile is solid within
    return solid?(level, character.x + x_step, character.y + y_step) ||
    solid?(level, character.x + x_step - CHARACTER_SIZE, character.y + y_step - CHARACTER_SIZE) ||
    solid?(level, character.x + x_step - CHARACTER_SIZE, character.y + y_step) || 
    solid?(level, character.x + x_step, character.y + y_step - CHARACTER_SIZE)
end 

def solid?(level, x, y)
  x += CHARACTER_SIZE
  y += CHARACTER_SIZE

  x = x / TILE_SIZE
  y = y / TILE_SIZE

  if x < 0 || x >= level.map_width || y < 0 || y >= level.map_height
    return false
  end

  return level.map_data[y][x].data.solid
end