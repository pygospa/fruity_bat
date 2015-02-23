Vec = struct.new(:x, :y) do
  def set!(other)
    x = other.x
    y = other.y
  end

  def +=(other)
    x += other.x
    y += other.y
  end
end


