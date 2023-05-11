
# Characters from images
module Tiles
    PLAYER = 1
end

class Player
    attr_accessor :health, :x, :y, :size, :id

    def initialize()
        @health = 3
        @x = 50
        @y = 50

        # for rendering which character
        @id = Tiles::PLAYER
    end
end