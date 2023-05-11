module Tiles
    SKY = 157
    DIRT = 5
    GRASS = 23
end

class TileMap
  attr_accessor :map_data, :map_height, :map_width

  def initialize(map_data)
    @map_data = map_data
    @map_height = map_data.length
    @map_width = map_data[0].length
  end
end
