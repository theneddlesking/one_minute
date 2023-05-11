require_relative 'tilemap.rb'
require_relative 'editor.rb'

require 'json'

class GameWindow < Gosu::Window
    WIDTH = 640
    HEIGHT = 480
    
    def initialize
      super(WIDTH, HEIGHT)
      @game_editor = Editor.new()

      @map_data = @game_editor.generate_basic_map(20, 10)

      @tile_map = TileMap.new(self, @map_data)
    end
    
    def draw
      @tile_map.draw
    end
end

game_editor = Editor.new()

game_editor.export_map_data()

GameWindow.new.show