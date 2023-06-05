class Menu
    attr_accessor :active, :message, :font, :x, :y

    def initialize()
        @active = false
        @message = ""
        @font = Gosu::Font.new(30)
        @x = 10
        @y = 425
    end
end