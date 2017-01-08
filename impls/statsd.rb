

def avg(lst)
  i = 0
  acc = 0
  lst.each do |x|
    acc += x
    i += 1
  end
  acc / i
end

timers = {}
counters = {}

while line = gets
  line = line.strip
  if line == 'flush'
    acc = []
    acc += counters.map { |k, v| "#{k}: #{v}" }
    acc += timers.map { |k, v| "#{k}: #{avg(v)}" }
    acc.sort!
    puts acc.join(', ')
    timers, counters = {}, {}
  elsif matches = /([a-zA-Z0-9]+):(\d+)\|([a-z]+)/.match(line)
    caps = matches.to_a.reject { |x| x.nil? }
    _, key, val, kind = caps.map { |x| x.strip }
    val = val.to_i
    if kind == 'c'
      counters[key] = counters.key?(key) ? counters[key] += val : counters[key] = val
    elsif kind == 'ms'
      timers[key] = timers.key?(key) ? timers[key] << val : timers[key] = [val]
    end
  end
end
