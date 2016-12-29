require 'mysql2'
require './utils'


class Papers
  def initialize(mysql)
    @table = 'papers'
    @m = mysql
    @log = get_logger
  end

  def standard(s)
    @m.escape(s.gsub(/\W+/, ' ').strip)
  end

  def create(name, link, description)
    name, link, description = [name, link, description].map { |x| @m.escape(x) }
    sql = "INSERT INTO #{@table} (name, link, description) VALUES ('#{name}', '#{link}', '#{description}')"
    results = @m.query(sql)
    @log.info("create: '#{sql}', #{results}")
    results
  end

  def list
    sql = "SELECT * FROM #{@table} ORDER BY id"
    results = @m.query(sql)
    @log.info("list: '#{sql}', #{results.to_a}")
    results
  end


end
