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
  if (expr.is_a? Sexp) && expr[0] == :call && expr[2] == :incr
    num_args = expr.slice(3, expr.size).size
    if num_args == 2
      snd = expr[4]
      if snd[0] == :lit && snd[1] == 1
        # remove the second value!
        expr.pop()
      end
    end
  elsif expr.is_a? Sexp
    expr.each do |x|
      rewrite(x)
    end
  end
  expr
end


puts Ruby2Ruby.new.process rewrite(parse(load))
