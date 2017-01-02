# coding: utf-8
require 'sinatra'
require 'mongo'
require 'json'
require './models/users'
require './models/papers'
require './models/user_papers'
require './models/systems'
require './models/system_papers'
require './models/user_systems'
require 'dalli'
require 'rack/session/dalli'
require 'redcarpet'

CLIENT_ID = ENV['GH_BASIC_CLIENT_ID']
CLIENT_SECRET = ENV['GH_BASIC_SECRET_ID']
MYSQL_HOST = ENV['MYSQL_HOST']
MYSQL_USER = ENV['MYSQL_USER']
MYSQL_PASS = ENV['MYSQL_PASS']
MYSQL_DB = ENV['MYSQL_DB']
MEMCACHE_HOSTS = ENV['MEMCACHE_HOSTS']
DOMAIN = ENV['DOMAIN']


configure do
  set :erb, :format => :html5
  use Rack::Session::Dalli, cache: Dalli::Client.new(MEMCACHE_HOSTS)
end

def get_markdown
  Redcarpet::Markdown.new(Redcarpet::Render::HTML, autolink: true, tables: true)
end

def get_mysql
  Mysql2::Client.new(:host => MYSQL_HOST, :username => MYSQL_USER, :password => MYSQL_PASS,
                     :database => MYSQL_DB, :automatic_close => true)
end

def error_page(status_code, msg)
  status status_code
  m = get_mysql
  cv = common_vars(m, status_code.to_s)
  cv[:status_code] = status_code
  cv[:error_msg] = msg
  erb :not_found, :locals => cv
end

not_found do
  error_page(404, "Not Found")
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
    :domain => DOMAIN,
    :title => title,
    :user => Users.new(m).get_by_token(access_token),
    :access_token => access_token,
    :paper_count => paper_count,
    :system_count => system_count
  }
end

def authenticated?
  session[:access_token]
end

get '/about/' do
  m = get_mysql
  cv = common_vars(m, "About")
  erb :about, :locals => cv
end

get '/logout/' do
  session.clear
  redirect '/'
end

get '/login/' do
  redirect "https://github.com/login/oauth/authorize?scope=user:email&client_id=#{CLIENT_ID}"
end

get '/' do
  m = get_mysql
  cv = common_vars(m, "Systems")
  cv[:systems] = Systems.new(m).list(:cols => ['id', 'name', 'completion_count'])
  if cv[:user]
    cv[:systems] = UserSystems.new(m).mark_completed(cv[:user]['id'], cv[:systems])
  end
  cv[:systems_table] = erb(:table_systems, :locals => cv, :layout=> nil)
  erb :systems, :locals => cv
end

get '/systems/:id/' do
  sid = params[:id]
  m = get_mysql
  cv = common_vars(m, "Papers")
  s = Systems.new(m)
  system = s.get('id', sid)
  if system
    related_papers = []
    cv[:system] = system
    cv[:papers] = SystemPapers.new(m).related_papers(sid)
    if cv[:user]
      uid = cv[:user]['id']
      cv[:upload_token] = upload_token(uid, sid)
      cv[:papers] = UserPapers.new(m).mark_read(uid, cv[:papers])
      cv[:has_completed] = UserSystems.new(m).has_completed(uid, sid)
    end
    cv[:papers_table] = erb(:table_papers, :locals => cv, :layout=> nil)
    cv[:submit_fragment] = erb(:submit_system, :locals => cv, :layout => nil)
    erb "systems/#{system['template']}".to_sym, :locals => cv
  else
    error_page(404, "No such system found.")
  end
end

get '/systems/:id/input/' do
  sid = params[:id]
  m = get_mysql
  s = Systems.new(m)
  system = s.get('id', sid)
  if system
    fn = "#{sid}_input.txt"
    send_file "solutions/#{system['template']}.in", :filename => fn
  else
    status 404
    body "No such system found."
  end
end

post '/systems/:id/output/' do
  token = params[:token]
  if token
    begin
      uid, sid, ts = decode_token(token.strip)
    rescue
      status 403
      return body "Supplied 'token' could not be validated."
    end
    if sid == params['id']
      m = get_mysql
      s = Systems.new(m)
      system = s.get('id', sid)
      solution = File.open("solutions/#{system['template']}.out")
      errors = 0
      lines = 0
      resp = ""
      for line in request.body
        sol_line = solution.gets
        lines += 1
        if line == sol_line
          resp += "✓ #{line}"
        else
          resp += "✗ #{line}"
          errors += 1
        end
      end
      if errors > 0 or lines == 0
        resp += "\nSorry, that doesn't look quite right. We found #{errors} errors.\n"
        status 400
        body resp
      else
        resp += "\nExcellent, that looks correct!\n"
        uss = UserSystems.new(m)
        already_solved = uss.has_completed(uid, sid)
        if already_solved
          resp += "You've already solved this problem.\n"
        else
          uss.create(uid, sid)
          count = uss.user_count(uid)
          Users.new(m).update(uid, :completion_count => count)
          Systems.new(m).incr(sid, 'completion_count')
          resp += "This is your first time solving this problem, congrats.\n"
        end
        status 200
        body resp
      end
    else
      status 400
      body "Supplied 'token' associated with system #{sid}, this is #{params['id']}."
    end
  else
    status 403
    body "Must supply 'token' parameter."
  end
end

get '/papers/' do
  m = get_mysql
  cv = common_vars(m, "Papers")
  papers = Papers.new(m).list(:cols => ['id', 'name', 'read_count', 'topic', 'rating', 'year'])
  if cv[:user]
    papers = UserPapers.new(m).mark_read(cv[:user]['id'], papers)
  end
  cv[:papers] = papers
  cv[:papers_table] = erb(:table_papers, :locals => cv, :layout=> nil)
  erb :papers, :locals => cv
end

get '/papers/:id/' do
  pid = params[:id]
  m = get_mysql
  p = Papers.new(m)
  paper = p.get('id', pid)
  if paper
    cv = common_vars(m, "")
    cv[:paper] = paper
    if cv[:user]
      cv[:has_read] = UserPapers.new(m).has_read(cv[:user]['id'], pid)
    else
      cv[:has_read] = nil
    end
    cv[:systems] = SystemPapers.new(m).related_systems(pid)
    cv[:systems_table] = erb(:table_systems, :locals => cv, :layout=> nil)
    cv[:rendered] = get_markdown.render(paper['description'])
    erb :paper, :locals => cv
  else
    error_page(404, "No such paper found.")
  end
end

get '/papers/:id/read' do
  m = get_mysql
  pid = params[:id]
  cv = common_vars(m, nil)
  if not params[:rating]
    return error_page(400, "Must supply 'rating' parameter.")
  end
  rating = params[:rating].to_i
  if rating < 1 or rating > 5
    return error_page(400, "Rating must be between 1 and 5, inclusive.")
  end

  if cv[:user]
    uid = cv[:user]['id']
    ups = UserPapers.new(m)
    ups.create(uid, pid, rating)
    count = ups.user_count(uid)
    avg = ups.rating(pid)
    Users.new(m).update(uid, :read_count => count)
    p = Papers.new(m)
    p.incr(pid, 'read_count')
    p.update(pid, :rating => avg)
    redirect "/papers/#{pid}/"
  else
    error_page(403, 'Must be logged in to mark paper as read.')
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
    error_page(403, 'Must be logged in as an admin.')
  end
end

get '/admin/users/' do
  m = get_mysql
  cv = common_vars(m, "Users")
  if cv[:user] and cv[:user]['is_admin']
    cv[:users] = Users.new(m).list
    erb :users, :locals => cv
  else
    error_page(403, 'Must be logged in as an admin.')
  end
end

# should only allow this if you're an admin
get '/admin/add-paper/' do
  m = get_mysql
  cv = common_vars(m, "Add Paper")
  if cv[:user] and cv[:user]['is_admin']
    erb :add, :locals => cv
  else
    error_page(403, 'Must be logged in as an admin.')
  end
end

post '/admin/add-paper/' do
  m = get_mysql
  cv = common_vars(m)
  if cv[:user] and cv[:user]['is_admin']
    Papers.new(m).create(params['name'], params['link'], params['description'], params['topic'], params['year'])
    redirect '/papers/'
  else
    error_page(403, 'Must be logged in as an admin.')
  end
end

get '/admin/add-system/' do
  m = get_mysql
  cv = common_vars(m, "Add System")
  if cv[:user] and cv[:user]['is_admin']
    erb :add_system, :locals => cv
  else
    error_page(403, 'Must be logged in as an admin.')
  end
end

post '/admin/add-system/' do
  m = get_mysql
  cv = common_vars(m)
  if cv[:user] and cv[:user]['is_admin']
    Systems.new(get_mysql).create(params['name'], params['template'])
    redirect '/'
  else
    error_page(403, 'Must be logged in as an admin.')
  end
end

get '/admin/associate/' do
  m = get_mysql
  cv = common_vars(m, "Associate Systems With Paper")
  if cv[:user] and cv[:user]['is_admin']
    cv[:systems] = Systems.new(m).list
    erb :associate_papers, :locals => cv
  else
    error_page(403, 'Must be logged in as an admin.')
  end
end

post '/admin/associate/' do
  m = get_mysql
  cv = common_vars(m)
  if cv[:user] and cv[:user]['is_admin']
    paper_id = params['paper_id']
    system_ids = params['system_id']
    SystemPapers.new(m).bulk_create(paper_id, system_ids)
    redirect "/papers/#{paper_id}/"
  else
    error_page(403, 'Must be logged in as an admin.')
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
