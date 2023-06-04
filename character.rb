require 'gosu'

# Characters from images
module Tiles
    PLAYER = 1
end

class Player
    attr_accessor :health, :x, :y, :x_velocity, :y_velocity, :size, :id, :max_x_velocity, :max_y_velocity, :width, :height

    def initialize()
        @health = 3
        @x = 450
        @y = 50

        @max_y_velocity = 6
        @max_x_velocity = 3

        @x_velocity = 0
        @y_velocity = 0

        @size = 24

        @height = @size
        @width = @size


        # for rendering which character
        @id = Tiles::PLAYER
    end
end