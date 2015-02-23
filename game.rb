require 'gosu'
require 'defstruct'

GRAVITY = 600 # pixels/s^2
JUMP_VEL = 300

GameState = DefStruct.new{{
  scroll_x: 0,
  player_y: 200,
  player_y_vel: 0,
}}

class GameWindow < Gosu::Window
  def initialize(*args)
    super
    @images = {
      background: Gosu::Image.new(self, 'images/background.png', false),
      foreground: Gosu::Image.new(self, 'images/foreground.png', true),
      player:  Gosu::Image.new(self, 'images/fruity_1.png', true),
    }

    @state = GameState.new
  end

  def button_down(button)
    close if button == Gosu::KbEscape

    if button == Gosu::KbSpace
      @state.player_y_vel = -JUMP_VEL
    end
  end

  def update
    @state.scroll_x +=3

    # Repeat - once scroll_x (foreground picture) is out of window, start from
    # zero:
    if @state.scroll_x > @images[:foreground].width
      @state.scroll_x = 0
    end

    # time difference between this and last frame
    dt = (update_interval/1000.0)

    # Movement: Gravity pulling on bat
    # Update interval is given bei Gosu and it's given in miliseconds. We
    # calculate the velocity in seconds, therefore the division by 1000.0
    @state.player_y_vel += GRAVITY * dt

    # Apply the calculated pull on every update to the bats y coordinate
    @state.player_y += @state.player_y_vel * dt 
  end

  def draw
    @images[:background].draw(0,0,0)
    @images[:foreground].draw(-@state.scroll_x,0,0)
    @images[:foreground].draw(-@state.scroll_x + @images[:foreground].width,0,0)
    @images[:player].draw(20,@state.player_y,0)
  end
end

window = GameWindow.new(320,480,false)
window.show
