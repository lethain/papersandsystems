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




end
