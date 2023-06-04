require 'gosu'

# Characters from images
module Tiles
    PLAYER = 1
end

class Player
    attr_accessor :health, :x, :y, :x_velocity, :y_velocity, :id, :jump_height

    def initialize()
        @health = 3
        @x = 450
        @y = 50

        @x_velocity = 0
        @y_velocity = 0

        @jump_height = 15

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
