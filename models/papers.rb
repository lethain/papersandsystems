require 'mysql2'
require './utils'


class Papers < PASModel
  def initialize(mysql)
    super(mysql, 'papers')
  end

  def create(name, link, description)
    name, link, description = [name, link, description].map { |x| self.escape(x) }
    sql = "INSERT INTO #{@table} (name, link, description) VALUES ('#{name}', '#{link}', '#{description}')"
    self.run(sql)
  end

  def list
    sql = "SELECT * FROM #{@table} ORDER BY id"
    self.run(sql)    
  end

end
