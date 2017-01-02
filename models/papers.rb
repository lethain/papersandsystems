require 'mysql2'
require './utils'


class Papers < PASModel
  def initialize(mysql)
    super(mysql, 'papers')
  end

  def create(name, link, description, topic, year)
    id = self.uuid
    pos = self.count() + 1    
    name, link, description = [name, link, description, topic, year].map { |x| self.escape(x) }
    sql = "INSERT INTO #{@table} (id, pos, name, link, description, topic, year) VALUES ('#{id}', '#{pos}', '#{name}', '#{link}', '#{description}', '#{topic}', '#{year}')"
    self.run(sql)
  end
end
