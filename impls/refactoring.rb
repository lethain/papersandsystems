# using ruby_parser from https://github.com/seattlerb/ruby_parser
# also ruby2ruby for convert sexps to ruby code: sudo gem install ruby2ruby
require 'ruby_parser'
require 'ruby2ruby'

def load
  txt = ''
  while line = gets
    txt += line
  end
  txt
end

def parse(txt)
  RubyParser.new.parse(txt)
end

def rewrite(expr)
  if expr.is_a? Sexp
    if expr[0] == :call
      num_args = expr.slice(3, expr.size).size
      if num_args == 2
        snd = expr[4]
        if snd[0] == :lit && snd[1] == 1
          # remove the second value!
          expr.pop()
        end
      end
    elsif expr[0] == :for
      lst = expr[1]
      param = expr[2]
      func = expr[3]
      expr.clear
      expr[0] = :iter
      expr[1] = Sexp.new(:call, lst, :each)
      expr[2] = Sexp.new(:args, param[1])
      expr[3] = func
    end
    expr.each do |x|
      rewrite(x)
    end
  end
  expr
end

rewritten = Ruby2Ruby.new.process rewrite(parse(load))
regex = /^(\s+)\((.*)\)\s*$/
rewritten = rewritten.split("\n").map do |line|
  if line =~ regex
    match = regex.match(line)    
    match[1] + match[2]
  else    
    line
  end
end
puts rewritten
