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
    args = ['Name', 'Link', 'Desc', 'Topic', '2017', 'Slug']
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
  end

  def test_paper_detail
    # view paper detail page
    # login and mark read
    # view again
  end

  def test_system_detail
    # view system
    # fail submit
    # login
    # fail submit
    # succeed submit
    # view page, should be updated
  end

  def test_add_paper
    # fail logged out
    # login
    # submit a new paper
  end


end
