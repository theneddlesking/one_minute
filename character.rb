require 'gosu'

# Characters from images
module Tiles
    PLAYER = 1
end

class Player
    attr_accessor :health, :x, :y, :x_velocity, :y_velocity, :size, :id, :max_velocity, :width, :height

    def initialize()
        @health = 3
        @x = 50
        @y = 250

        @max_velocity = 10

        @x_velocity = 0.0
        @y_velocity = 0.0

        @size = 24

        @height = @size
        @width = @size


        # for rendering which character
        @id = Tiles::PLAYER
    end
end