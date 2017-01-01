
class LoadBalancer
  def initialize(workers)
    @n = workers
    @q = []
    @n.times { |x| @q << [] }
    @l = 0
  end

  def depth(n)
    @q[n].size
  end

  def depths
    @q.map { |x| x.size }
  end

  def advance(n)
    @q.each do |worker|
      rem = n
      while rem > 0 and worker.size > 0
        first = worker[0]
        first -= rem
        if first <= 0
          rem = first.abs
          worker = worker.shift
        else
          worker[0] = first
          break
        end
      end
    end
  end

  def route(n)
    @q[@l] << n
    @l = (@l + 1) % @n
  end

  def to_s
    sizes = @q.map { |x| x.size }
    "LoadBalancer(#{sizes})"
  end
end


def readStdin
  while a = gets
    yield a
  end
end

def apply(lb, line)
  op, val_str = line.split()
  puts "# line: #{line}"
  val = val_str.to_i
  case op
  when 'a'
    lb.advance(val)
    puts "# #{lb.depths}"
  when 'r'
    lb.route(val)
  when 'd'
    puts lb.depth(val)
  end
end

if __FILE__ == $0
  lb = LoadBalancer.new(gets.to_i)
  readStdin { |x| apply(lb, x) }
end
