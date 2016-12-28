require 'sinatra'
require 'mongo'

set :erb, :format => :html5


def papers
  client = Mongo::Client.new('mongodb://127.0.0.1:27017/papers')
  db = client.database
  client[:papers]
end


get '/' do
  p = papers
  res = p.find.sort(:num => 1)
  erb :list, :locals => {:title => "Papers", :papers => res}
end


get '/paper/' do
  erb :add, :locals => {:title => "Add Paper"}
end



def standard(s)
  s.gsub(/\W+/, ' ').strip
end

post '/paper/' do
  p = papers
  doc = { name: params['name'],
          link: params['link'],
          desc: params['description']
        }
  doc.each { |k,v| doc[k] = standard(v) }
  doc[:num] = p.count + 1
  result = p.insert_one(doc)
  redirect '/'
end
