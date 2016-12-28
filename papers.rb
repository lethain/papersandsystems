require 'sinatra'
require 'mongo'
require 'json'
require './user'

set :erb, :format => :html5
use Rack::Session::Pool, :cookie_only => false


CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

def authenticated?
  session[:access_token]
end

def papers
  client = Mongo::Client.new('mongodb://127.0.0.1:27017/papers')
  db = client.database
  client[:papers]
end

get '/' do
  access_token = authenticated?
  user = get_user(access_token)

  p = papers
  res = p.find.sort(:num => 1)
  erb :list, :locals => {:title => "Papers", :papers => res, :client_id => CLIENT_ID, :user => user}
end

    

# {"error"=>"bad_verification_code", "error_description"=>"The code passed is incorrect or expired.", "error_uri"=>"https://developer.github.com/v3/oauth/#bad-verification-code"}

get '/callback' do
  session_code = request.env['rack.request.query_hash']['code']
  result = RestClient.post('https://github.com/login/oauth/access_token',
                           {:client_id => CLIENT_ID,
                            :client_secret => CLIENT_SECRET,
                            :code => session_code},
                           :accept => :json)
  parsed = JSON.parse(result)
  if parsed[:error]
    redirect "/?error_description=#{parsed[:error_description]}&error=#{parsed[:error]}"
  end
  access_token = parsed['access_token']
  scopes = parsed['scope'].split(',')
  has_user_email_scope = scopes.include? 'user:email'
  user = JSON.parse(RestClient.get('https://api.github.com/user',
                                   {:params => {:access_token => access_token}}))
  emails = JSON.parse(RestClient.get('https://api.github.com/user/emails',
                                     {:params => {:access_token => access_token}}))
  info, success = create_user(access_token, user, emails)
  if success
    session[:access_token] = parsed['access_token']
    redirect '/'
  else
    redirect '/?error_description=failed%20extracting%20email'
  end
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
