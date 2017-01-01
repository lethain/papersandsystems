

class RingBuffer
  def initialize(size)
    @size = size
    self.reset()
  end

  def reset
    @p = 0
    @l = 0
    @arr = [-1] * @size
  end

  def write(t, v)
    prev = @p+@l+1
    curr = t
    range = prev...curr
    range.each { |x| @arr[x%@size] = 0 }
    @arr[curr % @size] = v
    gap = range.to_a.length + 1
    @l = [@size, @l + gap].min
    @p = t - @l
  end

  def read(t)
    if t <= @p or t > @p + @l
      -1
    else
      @arr[(t - @p) % @size]
    end
  end

  def size
    @l
  end

  def to_s
    "RingBuffer(#{self.size})"
  end
end


def readStdin
  while a = gets
    yield a
  end
end

def apply(rb, line)
  case line[0]
  when 'w'
    _, t, v = line.split()
    rb.write(t.to_i, v.to_i)
  when 'r'
    _, t  = line.split()
    puts "#{t} #{rb.read(t.to_i)}"
  end
end


if __FILE__ == $0
  rb = RingBuffer.new(gets.to_i)
  readStdin { |x| apply(rb, x) }

end
