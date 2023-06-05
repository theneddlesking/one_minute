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


def level_complete(number)
    @menu.active = true
    @menu.message = "Level " + number.to_s + " Complete! Press [ENTER] for the next level"
  end
  
  def game_lose(menu)
    @menu.active = true
    @menu.message = "                 Game over! You ran out of time! \n                          Press [ENTER] to retry."
  end
  
  
  def game_win(menu)
    @menu.active = true
    @menu.message = "                   Congratulations! You win! \n If you want to play again, press [ENTER] to restart!"
  end
  
  def draw_editor_text(menu)
    @menu.message = "Editor Mode"
  end
  
  def draw_main_menu(menu)
    @menu.active = true
    @menu.message = "   One Minute Platformer by Ned Olsen \n  Use arrow keys and spacebar to move \n       Press [ENTER] to start!"
    @menu.x = 100
    @menu.y = 100
  end