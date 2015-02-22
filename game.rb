require 'gosu'

class GameWindow < Gosu::Window
  def initialize(*args)
    super

    @background = Gosu::Image.new(self, 'images/background.png', false)
  end

  def button_down(button)
    close if button == Gosu::KbEscape
  end

  def draw
    @background.draw(0,0,0)
  end
end

window = GameWindow.new(800,600,false)
window.show
