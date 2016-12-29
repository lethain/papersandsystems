require 'sinatra'
require 'mongo'
require 'json'
require './models/users'
require './models/papers'
require './models/systems'
require 'dalli'
require 'rack/session/dalli'

CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

configure do
  set :erb, :format => :html5
  use Rack::Session::Dalli, cache: Dalli::Client.new('127.0.0.1:11211')
end

def get_mysql
  @m = Mysql2::Client.new(:host => "localhost", :username => "root", :database => "papers")

end

def common_vars(m, title)
  access_token = authenticated?
  {
    :title => title,
    :user => Users.new(m).get_by_token(access_token),
    :client_id => CLIENT_ID,
    :access_token => access_token,
    :user_paper_count => 0,
    :user_problem_count => 0,
    :paper_count => 5,
    :problem_count => 4
  }
end

def authenticated?
  session[:access_token]
end

get '/' do
  m = get_mysql
  cv = common_vars(m, "Systems")
  cv[:papers] = Systems.new(m).list
  erb :systems, :locals => cv
end

get '/papers/' do
  m = get_mysql
  cv = common_vars(m, "Papers")
  cv[:papers] = Papers.new(m).list
  erb :list, :locals => cv
end

# should only allow this if you're an admin
get '/paper/' do
  m = get_mysql
  cv = common_vars(m, "Add Paper")
  erb :add, :locals => cv
end

post '/paper/' do
  Papers.new(get_mysql).create(params['name'], params['link'], params['description'])
  redirect '/'
end



# for ELB health checks
get '/health' do
  status 200
  body 'Papers are OK'
end

# for synchronizing accounts with github
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

  info, success = Users.new(get_mysql).create(access_token, user, emails)
  if success
    session[:access_token] = parsed['access_token']
    redirect '/'
  else
    redirect '/?error_description=failed%20extracting%20email'
  end
end
