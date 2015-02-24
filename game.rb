require 'gosu'
require 'defstruct'
require_relative 'vector'

GRAVITY = Vec[0,600]    # pixel/s^2
JUMP_VEL = Vec[0,-300]  # pixel/s
OBSTACLE_SPEED = 200    # pixel/s
OBSTACLE_SPAWN_INTERVAL = 1.3 # seconds
OBSTACLE_GAP = 100      # pixel
DEATH_VELOCITY = Vec[50, -500] # pixel/s
DEATH_ROTATIONAL_VEL = 360 # degree/sec

Rect = DefStruct.new{{
  pos: Vec[0,0],
  size: Vec[0,0],
}}.reopen do
  def min_x; pos.x; end
  def min_y; pos.y; end
  def max_x; pos.x + size.x; end
  def max_y; pos.y + size.y; end
end

GameState = DefStruct.new{{
  alive: true,
  scroll_x: 0,
  player_pos: Vec[20,0],
  player_vel: Vec[0,0],
  player_rotation: 0,
  obstacles: [], # array of Vec
  obstacle_countdown: OBSTACLE_SPAWN_INTERVAL
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
    case button
    when Gosu::KbEscape then close
    when Gosu::KbSpace then @state.player_vel.set!(JUMP_VEL) if @state.alive
    end
  end

  def update
    dt = (update_interval/1000.0)
    @state.scroll_x += dt*OBSTACLE_SPEED*0.5

    # Repeat - once scroll_x (foreground picture) is out of window, start from
    # zero:
    if @state.scroll_x > @images[:foreground].width
      @state.scroll_x = 0
    end

    # Movement: Gravity pulling on bat
    # Update interval is given bei Gosu and it's given in miliseconds. We
    # calculate the velocity in seconds, therefore the division by 1000.0
    @state.player_vel += dt*GRAVITY 

    # Apply the calculated pull on every update to the bats y coordinate
    @state.player_pos += dt*@state.player_vel

    # Countdown 
    @state.obstacle_countdown -= dt
    if @state.obstacle_countdown <= 0
      @state.obstacles << Vec[width, rand(50..320)]
      @state.obstacle_countdown += OBSTACLE_SPAWN_INTERVAL
    end

    @state.obstacles.each do |obst|
      obst.x -= dt*OBSTACLE_SPEED
    end

    if @state.alive && player_is_colliding?
      @state.alive = false
      @state.player_vel.set!(DEATH_VELOCITY)
    end

    unless @state.alive
      @state.player_rotation += dt*DEATH_ROTATIONAL_VEL
    end
  end

  def player_is_colliding?
    player_r = player_rect
    obstacles_rects.find { |obst_r| rects_intersect?(player_r, obst_r) }
  end

  def rects_intersect?(r1, r2)
    # totally to the left or right of r2
    return false if r1.max_x < r2.min_x
    return false if r1.min_x > r2.max_x

    # totally to the top or bottom of r2
    return false if r1.min_y > r2.max_y
    return false if r1.max_y < r2.min_y

    true
  end

  def draw
    @images[:background].draw(0,0,0)
    @images[:foreground].draw(-@state.scroll_x,0,0)
    @images[:foreground].draw(-@state.scroll_x + @images[:foreground].width,0,0)

    img_y = @images[:obstacle].height
    # top log
    @state.obstacles.each do |obst|
      @images[:obstacle].draw(obst.x,-img_y + obst.y,0)
      scale(1,-1) do
        # bottom log
        @images[:obstacle].draw(obst.x, -height - img_y + (height - obst.y - OBSTACLE_GAP), 0)
      end
    end

    @images[:player].draw_rot(
      @state.player_pos.x,@state.player_pos.y,
      0, @state.player_rotation,
      0,0)


#   debug_draw
  end

  def player_rect
    Rect.new(
      pos: @state.player_pos,
      size: Vec[@images[:player].width, @images[:player].height])
  end

  def obstacles_rects
    img_y = @images[:obstacle].height
    obst_size = Vec[@images[:obstacle].width, @images[:obstacle].height]

    @state.obstacles.flat_map do |obst|
      top = Rect.new(pos: Vec[obst.x, obst.y - img_y],size: obst_size)
      bottom = Rect.new(pos: Vec[obst.x, obst.y + OBSTACLE_GAP],size: obst_size)
      [top,bottom]
    end
  end

  def debug_draw
    color = player_is_colliding? ? Gosu::Color::RED : Gosu::Color::GREEN
    draw_debug_rect(player_rect, color)

    obstacles_rects.each do |obst_rect|
      draw_debug_rect(obst_rect)
    end
  end

  def draw_debug_rect(rect, color = Gosu::Color::GREEN)
    x = rect.pos.x
    y = rect.pos.y
    w = rect.size.x
    h = rect.size.y

    points=[
      Vec[x, y],
      Vec[x+w, y],
      Vec[x+w, y+h],
      Vec[x, y+h]
    ]

    points.each_with_index do |p1, idx|
      p2 = points[(idx + 1) % points.size]
      draw_line(p1.x, p1.y, color, p2.x, p2.y, color)
    end
  end
end


window = GameWindow.new(320,480,false)
window.show
