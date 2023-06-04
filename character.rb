require 'gosu'

# Characters from images
module Tiles
    PLAYER = 1
end

class Player
    attr_accessor :x, :y, :x_velocity, :y_velocity, :id, :jump_height, :beat_level, :start_x, :start_y

    def initialize()
        @start_x = 450
        @start_y = 50

        @x = @start_x
        @y = @start_y

        @x_velocity = 0
        @y_velocity = 0

        @jump_height = 15

        @beat_level = false

        # for rendering which character
        @id = Tiles::PLAYER
    end
end

class Enemy 
    attr_accessor :x, :y, :x_velocity, :y_velocity, :id, :path

    def initialize()
        @x = 50
        @y = 50

        @x_velocity = 0
        @y_velocity = 0

        # a sequence of horizontal movements for the enemy to follow
        @path = []

        # for rendering which character
        @id = Tiles::PLAYER
    end
end
