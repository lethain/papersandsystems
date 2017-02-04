# coding: utf-8
ENV['RACK_ENV'] = 'test'

require './papers'
require 'test/unit'
require 'rack/test'
require 'rack/session/dalli'
require 'nokogiri'

class HelloWorldTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def initialize(*args)
    super(*args)
    @tables = create_tables
  end

  def app
    Sinatra::Application
  end

  def login_user
    m = mysql
    at = 'test_token'
    emails = [{'verified' => true, 'primary' => true, 'email' => 'test@example.org'}]
    user = {'id' => 1, 'login' => 'test_user', 'avatar_url' => 'fake-url'}
    info, success = Users.new(m).create(at, user, emails)
    assert_equal true, success
    post '/test-login/'
    assert last_response.ok?
  end

  def test_login
    # login button should exist when logged out
    get '/'
    assert last_response.ok?
    doc = Nokogiri::HTML(last_response.body)
    login = doc.css("#login")
    assert_equal 1, login.size

    # login button is gone
    login_user
    get '/'
    assert last_response.ok?
    doc = Nokogiri::HTML(last_response.body)
    login = doc.css("#login")
    assert_equal 0, login.size

    # logout
    get '/logout/'

    # login button is back
    get '/'
    assert last_response.ok?
    doc = Nokogiri::HTML(last_response.body)
    login = doc.css("#login")
    assert_equal 1, login.size
  end

  def test_systems_list
    drop_tables(@tables)
    s = Systems.new(mysql)
    args = ['System 1', 'system_1']
    (0..2).each do |n|
      get '/'
      assert last_response.ok?
      doc = Nokogiri::HTML(last_response.body)
      rows = doc.css("tbody tr")
      assert_equal n, rows.size
      rows.each do |row|
        cols = row.css("td").map { |x| x.text }
        assert_equal ["System 1", "0 engineers", "New"], cols
      end
      s.create(*args)
    end
  end

  def test_papers_list
    drop_tables(@tables)
    p = Papers.new(mysql)
    slug = "slug"
    args = ['Name', 'Link', 'Desc', 'Topic', '2017', slug]
    (0..2).each do |n|
      get '/papers/'
      assert last_response.ok?
      doc = Nokogiri::HTML(last_response.body)
      rows = doc.css("tbody tr")
      assert_equal n, rows.size
      rows.each do |row|
        cols = row.css("td").map { |x| x.text }
        assert_equal ['Name', '2017', 'Topic', ''], cols
      end
      p.create(*args)
    end

    # login and mark read
    login_user
    get "/papers/#{slug}/read/?rating=4"
    assert_equal 302, last_response.status
    get '/papers/'
    assert last_response.ok?
    doc = Nokogiri::HTML(last_response.body)
    rows = doc.css("tbody tr")
    r1_cols = rows[0].css("td").map { |x| x.text }
    assert_equal ['Name', '2017', 'Topic', '★★★★', '✓'], r1_cols

    r2_cols = rows[1].css("td").map { |x| x.text }
    assert_equal ['Name', '2017', 'Topic', '', ''], r2_cols
  end

  def test_paper_detail
    slug = 'slug'
    args = ['Name', 'Link', 'Desc', 'Topic', '2017', slug]
    p = Papers.new(mysql)
    p.create(*args)

    # view paper detail page
    get "/papers/#{slug}/"
    assert last_response.ok?
    assert_nil last_response.body =~ /You read this paper/

    # login and mark read
    login_user

    # must have a rating!
    get "/papers/#{slug}/read/"
    assert_equal last_response.status, 400
    get "/papers/#{slug}/read/?rating=0"
    assert_equal last_response.status, 400
    get "/papers/#{slug}/read/?rating=6"
    assert_equal last_response.status, 400
    get "/papers/#{slug}/read/?rating=4"
    assert_equal last_response.status, 302

    # view again
    get "/papers/#{slug}/"
    assert last_response.ok?
    assert_not_nil last_response.body =~ /You read this paper/
  end

  def test_system_detail
    drop_tables(@tables)

    # view non-existant system
    get '/systems/introduction/'
    assert_equal 404, last_response.status
    get '/systems/introduction/input/'
    assert_equal 404, last_response.status

    # create the system
    s = Systems.new(mysql)
    args = ['Introduction', 'introduction']
    s.create(*args)

    # view system
    get '/systems/introduction/'
    assert_equal 200, last_response.status

    # get input
    get '/systems/introduction/input/'
    assert_equal 200, last_response.status
    sys_input = last_response.body

    # submit output, logged out
    post '/systems/introduction/output/', "2\3\4"
    assert_equal 403, last_response.status

    post '/systems/introduction/output/?token=123', "2\3\4"
    assert_equal 403, last_response.status

    # login & get access token
    login_user
    get '/systems/introduction/'
    assert_equal 200, last_response.status
    token = last_response.body.scan(/var token = "(.*)"\n/).first.first

    # fail submit with wrong answer
    post "/systems/introduction/output/?token=#{token}", '2\n3\n4'
    assert_equal 400, last_response.status

    # fail submit with empty answer
    post "/systems/introduction/output/?token=#{token}", ''
    assert_equal 400, last_response.status

    # succeed submit
    puts sys_input.split("\n")
    lines = sys_input.split("\n").select { |x| x.strip }
    answers = lines.map do |line|
      (line.to_i * 3).to_s
    end
    post "/systems/introduction/output/?token=#{token}", answers.join("\n") + "\n"
    assert_equal 200, last_response.status

    post "/systems/introduction/output/?token=#{token}", answers.join("\n")
    puts "response: #{last_response.body}"
    assert_equal 200, last_response.status

    # view page, should be updated
  end

  def test_add_paper
    # fail logged out
    # login
    # submit a new paper
  end


  def test_about
    get '/about/'
    assert last_response.ok?
    login_user
    get '/about/'
    assert last_response.ok?
  end


end
