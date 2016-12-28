require 'pdf-reader'

def preceeding(s)
  s.index(/[^ ]/)
end

def tabs(s)
  t = 0
  for c in s.split("")
    if c == ' '
      t += 1
    end
  end
  t
  
end


def parse(filename)
  reader = PDF::Reader.new(filename)
  first = reader.pages.first.to_s
  i = 0
  for line in first.split("\n")
    puts "#{i}, #{tabs line}: #{line}"
    i += 1
  end

end

parse(ARGV[0])


