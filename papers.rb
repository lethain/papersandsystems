require 'sinatra'
require 'mongo'
require 'json'
require './models/users'
require './models/papers'
require './models/user_papers'
require './models/systems'
require 'dalli'
require 'rack/session/dalli'
require 'redcarpet'

CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']

configure do
  set :erb, :format => :html5
  use Rack::Session::Dalli, cache: Dalli::Client.new('127.0.0.1:11211')
end

def get_markdown
  Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
end

def get_mysql
  Mysql2::Client.new(:host => "localhost", :username => "root", :database => "papers")
end

def get_counts(m)
  pc = Papers.new(m).count()
  sc = Systems.new(m).count()
  return sc, pc
end

def common_vars(m, title=nil)
  access_token = authenticated?
  system_count, paper_count = get_counts(m)
  {
    :title => title,
    :user => Users.new(m).get_by_token(access_token),
    :client_id => CLIENT_ID,
    :access_token => access_token,
    :paper_count => paper_count,
    :system_count => system_count
  }
end

def authenticated?
  session[:access_token]
end

get '/' do
  m = get_mysql
  cv = common_vars(m, "Systems")
  cv[:systems] = Systems.new(m).list
  erb :systems, :locals => cv
end

get '/systems/:id/' do
  sid = params[:id]
  m = get_mysql
  cv = common_vars(m, "Papers")
  s = Systems.new(m)
  system = s.get('id', sid)
  if system
    puts "system: #{system}"
    related_papers = []
    cv[:system] = system
    cv[:related_papers] = related_papers
    has_solved = nil
    cv[:has_solved] = has_solved

    erb system['template'].to_sym, :locals => cv

  else
    status 404
    body "No such system found."
  end
end


get '/papers/' do
  m = get_mysql
  cv = common_vars(m, "Papers")
  papers = Papers.new(m).list(:cols => ['id', 'name', 'read_count'])
  if cv[:user]
    papers = UserPapers.new(m).mark_read(cv[:user]['id'], papers)
  end
  cv[:papers] = papers
  erb :papers, :locals => cv
end

get '/papers/:id/' do
  pid = params[:id]
  m = get_mysql
  p = Papers.new(m)
  paper = p.get('id', pid)
  if paper
    cv = common_vars(m, "")
    puts "read: #{pid}, #{cv[:user]['id']}"
    cv[:paper] = paper
    cv[:has_read] = UserPapers.new(m).has_read(cv[:user]['id'], pid)
    related_systems = []
    cv[:systems] = related_systems
    cv[:rendered] = get_markdown.render(paper['description'])
    erb :paper, :locals => cv
  else
    status 404
    body "No such paper found."
  end
end

get '/papers/:id/read' do
  m = get_mysql
  pid = params[:id]
  cv = common_vars(m, nil)
  if cv[:user]
    uid = cv[:user]['id']
    ups = UserPapers.new(m)
    ups.create(uid, pid)
    count = ups.user_count(uid)
    Users.new(m).update(uid, :read_count => count)
    Papers.new(m).incr(pid, 'read_count')
    redirect "/papers/#{pid}/"
  else
    status 403
    body "Must be logged in to read paper."
  end
end


get '/admin/recent/' do
  m = get_mysql
  cv = common_vars(m, "Users")
  if cv[:user] and cv[:user]['is_admin']
    cv[:users] = Users.new(m).list({:sort => 'ts desc', :limit => 10})
    cv[:read] = []
    cv[:completed] = []
    cv[:papers] = Papers.new(m).list({:sort => 'ts desc', :limit => 10})
    cv[:systems] = Systems.new(m).list({:sort => 'ts desc', :limit => 10})
    erb :recent, :locals => cv
  else
    status 403
    body 'Must be logged in as an admin.'
  end
end

get '/admin/users/' do
  m = get_mysql
  cv = common_vars(m, "Users")
  if cv[:user] and cv[:user]['is_admin']
    cv[:users] = Users.new(m).list
    erb :users, :locals => cv
  else
    status 403
    body 'Must be logged in as an admin.'
  end
end


# should only allow this if you're an admin
get '/admin/add-paper/' do
  m = get_mysql
  cv = common_vars(m, "Add Paper")
  if cv[:user] and cv[:user]['is_admin']
    erb :add, :locals => cv
  else
    status 403
    body 'Must be logged in as an admin.'    
  end
end

post '/admin/add-paper/' do
  m = get_mysql
  cv = common_vars(m)
  if cv[:user] and cv[:user]['is_admin']  
    Papers.new(m).create(params['name'], params['link'], params['description'])
    redirect '/papers/'
  else
    status 403
    body 'Must be logged in as an admin.'
  end
end

get '/admin/add-system/' do
  m = get_mysql
  cv = common_vars(m, "Add System")
  if cv[:user] and cv[:user]['is_admin']
    erb :add_system, :locals => cv
  else
    status 403
    body 'Must be logged in as an admin.'
  end
end

get '/admin/associate/' do
  m = get_mysql
  cv = common_vars(m, "Associate Systems With Paper")
  if cv[:user] and cv[:user]['is_admin']
    cv[:systems] = Systems.new(m).list
    erb :associate_papers, :locals => cv
  else
    status 403
    body 'Must be logged in as an admin.'
  end
end

post '/admin/associate/' do
  m = get_mysql
  cv = common_vars(m)
  if cv[:user] and cv[:user]['is_admin']
    puts "params: #{params}"
    body params.to_s
  else
    status 403
    body 'Must be logged in as an admin.'
  end
end

post '/admin/add-system/' do
  m = get_mysql
  cv = common_vars(m)
  if cv[:user] and cv[:user]['is_admin']
    Systems.new(get_mysql).create(params['name'], params['template'])
    redirect '/'
  else
    status 403
    body 'Must be logged in as an admin.'
  end
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
