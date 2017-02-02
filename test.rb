ENV['RACK_ENV'] = 'test'

require './papers'
require 'test/unit'
require 'rack/test'
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

  def test_papers_empty
    drop_tables(@tables)
    get '/papers/'
    assert last_response.ok?
    doc = Nokogiri::HTML(last_response.body)
    rows = doc.css("tbody tr")
    assert_equal 0, rows.size
  end

  def test_papers_not_empty
    drop_tables(@tables)
    p = Papers.new(mysql)
    (1..2).each do |n|
      p.create('Name', 'Link', 'Desc', 'Topic', '2017', 'Slug')
      get '/papers/'
      assert last_response.ok?
      doc = Nokogiri::HTML(last_response.body)
      rows = doc.css("tbody tr")
      assert_equal n, rows.size      
    end
  end  


end
