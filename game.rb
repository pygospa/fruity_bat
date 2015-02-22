require 'gosu'

class GameWindow < Gosu::Window
  def initialize(*args)
    super
    @scroll_x = 0
    @background = Gosu::Image.new(self, 'images/background.png', false)
    @foreground = Gosu::Image.new(self, 'images/foreground.png', false)
  end

  def button_down(button)
    close if button == Gosu::KbEscape
  end

  def update
    @scroll_x +=3

    # Repeat - once scroll_x (foreground picture) is out of window, start from
    # zero:
    if @scroll_x > @foreground.width
      @scroll_x = 0
    end
  end

  def draw
    @background.draw(0,0,0)
    @foreground.draw(@scroll_x,0,0)
    
  end
end

window = GameWindow.new(320,480,false)
window.show
