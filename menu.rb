class Menu
    attr_accessor :active, :message, :font

    def initialize()
        @active = false
        @message = ""
        @font = Gosu::Font.new(30)
    end
end