require_relative 'character.rb'

TILE_SIZE = 18
CHARACTER_SIZE = 24

def apply_physics(level, player, entity)
  # steps per frame, max of 1 to avoid going inside tiles
  step = 1

  # gravity
  entity.y_velocity += step

  y_step = step * sign(entity.y_velocity)
  
  entity.y_velocity.abs.times { if !character_hit_tiles?(player, level, entity, 0, y_step) then entity.y += y_step else entity.y_velocity = 0 end }
  
  # Directional walking, horizontal movement
  x_step = step * sign(entity.x_velocity)

  # Step in the direction of the entity's velocity until it hits a wall
  entity.x_velocity.abs.times { if !character_hit_tiles?(player, level, entity, x_step, 0) then entity.x += x_step end }

  # Velocity has been used up
  entity.x_velocity = 0
end

def jump(level, player)
  # looks just at the feet of the player, also checks slightly to left and right so you can edge jump
  if solid?(player, player, level, player.x, player.y + 1) || solid?(player, player, level, player.x - CHARACTER_SIZE, player.y + 1)
    player.y_velocity = -@player.jump_height
  end
end

# used for getting the step in the direction of the velocity
def sign(x)
  if (x > 0) 
    return 1
  end
  if (x < 0) 
    return -1
  end
  return 0
end

def character_hit_tiles?(player, level, character, x_step, y_step)
    # Checks if tile is solid within
    return solid?(player, character, level, character.x + x_step, character.y + y_step) ||
    solid?(player, character, level, character.x + x_step - CHARACTER_SIZE, character.y + y_step - CHARACTER_SIZE) ||
    solid?(player, character, level, character.x + x_step - CHARACTER_SIZE, character.y + y_step) || 
    solid?(player, character, level, character.x + x_step, character.y + y_step - CHARACTER_SIZE)
end

def get_current_tile(level, x, y)
  x = x / TILE_SIZE
  y = y / TILE_SIZE

  if (off_map?(level, x + 1, y + 1))
    return nil
  end

  return level.map_data[y + 1][x + 1]
end

def solid?(player, character, level, x, y)

  # Also check if we hit the tile

  x += CHARACTER_SIZE
  y += CHARACTER_SIZE

  # When we hit a tile we need to check if it has a special mechanic (we need to check this often for collectables to update as we move)
  if (character.id == Characters::PLAYER)
    tile = get_current_tile(level, player.x, player.y)
    activate_tile(character, tile, level)
    tile = get_current_tile(level, player.x - CHARACTER_SIZE / 2, player.y - CHARACTER_SIZE / 2)
    activate_tile(character, tile, level)
    tile = get_current_tile(level, player.x - CHARACTER_SIZE / 2, player.y)
    activate_tile(character, tile, level)
    tile = get_current_tile(level, player.x, player.y - CHARACTER_SIZE / 2)
    activate_tile(character, tile, level)
  end

  x = x / TILE_SIZE
  y = y / TILE_SIZE

  if off_map?(level, x, y)
    return false
  end
  
  tile = level.map_data[y][x]

  # Lock tiles are solid until you have a key
  return tile.data.solid || (tile.data.mechanic == Mechanics::LOCK && !player.has_key)
end

def off_map?(level, x, y)
  return x < 0 || x >= level.map_width || y < 0 || y >= level.map_height
end