# a part of the level with some mechanics
class LevelComponent
    attr_accessor :x, :y, :level

    def initialize(x, y, level)
        @x = x
        @y = y
        @level = level
    end
end
