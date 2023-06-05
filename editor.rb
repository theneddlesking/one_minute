class Editor 
    attr_accessor :tile_sets, :current_tile_set, :level, :tile_pos, :key_states

    def initialize(level)
        @tile_sets = [
            # Blocks    
            TileSet.new([Tiles::SKY, Tiles::DIRT, Tiles::GRASS], Gosu::KB_B),
            # Collectables    
            TileSet.new([Tiles::COIN, Tiles::DIAMOND, Tiles::KEY], Gosu::KB_C),
            # Mechanics   
            TileSet.new([Tiles::FLAG1, Tiles::FLAG2, Tiles::LADDER1, Tiles::LADDER2, Tiles::SPIKE, Tiles::LOCK, Tiles::SPRING], Gosu::KB_M),
            # Decoration   
            TileSet.new([Tiles::BUSH1, Tiles::BUSH2, Tiles::BUSH3, Tiles::BUSH4, Tiles::BUSH5], Gosu::KB_D),
        ]
        @current_tile_set = tile_sets[0]
        @level = level
        @tile_pos = [0, 0]

        # holds data of whether a particular key was pressed, used for detecting single key
        @key_states = {}
    end
end

def get_next_tile_of_set(set, direction)
    set.current_index += direction

    if (set.current_index == -1)
        set.current_index = set.tile_count - 1
    end

    # wraps index back to 0
    if (set.current_index == set.tile_count)
        set.current_index = 0
    end


    tile = set.current_tile

    set_tile(set, set.current_index)
end

def set_tile(set, tile_index)
    set.current_tile = set.tiles[tile_index]
end

def update_editor(editor)
    # read inputs of potential shortcuts

    # shortcut to get previous tile
    swap_tile_shortcut(editor, -1)

    # shortcut to get next tile
    swap_tile_shortcut(editor, 1)

    # shortcut to save the current map
    save_map_shortcut(editor)

    # shortcut to write a new tile
    write_tile_shortcut(editor)

    # select any clicked tile
    select_tile_if_clicked(editor)

    # reads tile set shortcuts
    editor.tile_sets.each { |tile_set| select_tile_set(editor, tile_set) }
end

def swap_tile_shortcut(editor, direction)
    if direction == 1 && button_up?(Gosu::KbRight, editor.key_states)
        get_next_tile_of_set(editor.current_tile_set, direction)
    elsif direction == -1 && button_up?(Gosu::KbLeft, editor.key_states)
        get_next_tile_of_set(editor.current_tile_set, direction)
    end
end

def save_map_shortcut(editor)
    if (button_up?(Gosu::KB_S, editor.key_states))
        puts("save data")
        export_map_data(editor.level.map_data)
    end
end

def select_tile_set(editor, tile_set)
    if (button_down?(tile_set.shortcut))
        # the editor selects the new tile set 
        editor.current_tile_set = tile_set

        tile_set.current_index = 0

        # starts at the first tile
        set_tile(tile_set, 0)
    end
end

def button_up?(button, key_states)
    if button_down?(button) && !key_states[button]
        key_states[button] = true
        return true;
    elsif !button_down?(button)
        key_states[button] = false
    end
    return false
end

def select_tile_if_clicked(editor)
    if (button_down?(Gosu::MsLeft))
        tile_pos = mouse_over_tile(mouse_x, mouse_y)
        editor.tile_pos = tile_pos
    end
end

def mouse_over_tile(mouse_x, mouse_y)
    if mouse_x <= TILE_SIZE
      cell_x = 0
    else
      cell_x = (mouse_x / TILE_SIZE).to_i
    end

    if mouse_y <= TILE_SIZE
      cell_y = 0
    else
      cell_y = (mouse_y / TILE_SIZE).to_i
    end

    [cell_x, cell_y]
end

def write_tile_shortcut(editor)
    if (Gosu::KB_RETURN)
        map_data = editor.level.map_data

        x = editor.tile_pos[0]
        y = editor.tile_pos[1]
        tile = editor.current_tile_set.current_tile
        map_data[y][x] = Tile.new(tile, x, y)
    end
end