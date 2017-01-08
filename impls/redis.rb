

def output(l)
  STDOUT.write "#{l}\r\n"
end

LSTS = {}

def length(key)
  LSTS.has_key?(key) ? LSTS[key].length : 0
end

def handle(cmd)
  #puts "#{cmd}"
  case cmd.first.downcase
  when "llen"
    len = length(cmd[1])
    output(":#{len}")
  when "lpush"
    key = cmd[1]
    if not LSTS.has_key?(key)
      LSTS[key] = []
    end
    LSTS[key] = cmd.slice(2, cmd.length).reverse + LSTS[key]
    len = length(key)
    output(":#{len}")
  when "lpop"
    key = cmd[1]
    if not LSTS.has_key?(key) or LSTS[key].length == 0
      output("$-1")
    else
      first = LSTS[key].shift
      output("$#{first.to_s.length}")
      output("#{first.to_s}")
    end
  when "lrange"
    key = cmd[1]    
    if not LSTS.has_key?(key) or LSTS[key].length == 0
      output("*0")
    else
      sp = cmd[2].to_i
      ep = cmd[3].to_i
      vals = LSTS[key].slice(sp, ep-sp+1)

      output("*#{vals.length}")
      vals.each do |val|
        output("$#{val.to_s.length}")
        output(val.to_s)
      end
    end
  else
    puts "unknown command"
  end
end

acc = []
rem = 0
size = 0
while line = gets
  if rem == 0
    rem = line.slice(1, line.length).strip.to_i
  elsif size == 0
    size = line.slice(1, line.length).strip.to_i
  else
    acc << line.slice(0, size)
    size = 0
    rem -= 1
  end
  if rem == 0
    handle(acc)
    acc = []
  end
end
