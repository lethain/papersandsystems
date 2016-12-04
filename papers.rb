require 'sinatra'
set :erb, :format => :html5


get '/' do
  erb :list, :locals => {:title => "Papers"}
end
