


while line = gets
  print line.strip.gsub(/\.\./, "\r\n")
end
