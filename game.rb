require 'gosu'

class GameWindow < Gosu::Window
  def button_down(button)
    close if button == Gosu::KbEscape
  end
end

window = GameWindow.new(800,600,false)
window.show
