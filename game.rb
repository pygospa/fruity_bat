require 'gosu'
require 'defstruct'

GRAVITY = Vec[0,600]    # pixel/s^2
JUMP_VEL = Vec[0,300]   # pixel/s


Obstacle = DefStruct.new{{
  x: 0,
  y: 0,
}}
  

GameState = DefStruct.new{{
  scroll_x: 0,
  palyer_pos: Vec[0,0],
  player_vel: Vec[0,0],
}}

class GameWindow < Gosu::Window
  def initialize(*args)
    super
    @images = {
      background: Gosu::Image.new(self, 'images/background.png', false),
      foreground: Gosu::Image.new(self, 'images/foreground.png', true),
      player:  Gosu::Image.new(self, 'images/fruity_1.png', false),
      obstacle: Gosu::Image.new(self, 'images/obstacle.png', false),
    }

    @state = GameState.new
  end

  def button_down(button)
    close if button == Gosu::KbEscape

    if button == Gosu::KbSpace
      @state.player_vel.set!(JUMP_VEL)
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
    @state.player_vel += dt*GRAVITY 

    # Apply the calculated pull on every update to the bats y coordinate
    @state.player_pos.y += @state.player_vel.y * dt 
  end

  def draw
    @images[:background].draw(0,0,0)
    @images[:foreground].draw(-@state.scroll_x,0,0)
    @images[:foreground].draw(-@state.scroll_x + @images[:foreground].width,0,0)
    @images[:player].draw(20,@state.player_pos.y,0)

    @images[:obstacle].draw(200,-300,0)
    scale(1,-1) do
      @images[:obstacle].draw(200,-height-400,0)
    end
  end
end

window = GameWindow.new(320,480,false)
window.show
