Vec = Struct.new(:x, :y) do
  def set!(other)
    self.x = other.x
    self.y = other.y
    self
  end

  def +(other)
    Vec[x + other.x, y + other.y]
  end

  def -(other)
    Vec[x - other.x, y - other.y]
  end

  def *(scalar)
    Vec[x*scalar, y*scalar]
  end

  def -@
    Vec[-x,-y]
  end

  # 5*Vec will yield an error, becuase ruby expects vec*scalar.
  # Therfore above method will create an error!
  #     Vec can't be coerced into Fixnum
  # The coerce function fixes this by switching the positions!
  def coerce(left)
    [self,left]
  end
end


