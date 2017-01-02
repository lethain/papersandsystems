require 'mysql2'
require './utils'


class Papers < PASModel
  def initialize(mysql)
    super(mysql, 'papers')
  end

  def create(name, link, description, topic, year)
    name, link, description = [name, link, description, topic, year].map { |x| self.escape(x) }
    sql = "INSERT INTO #{@table} (name, link, description, topic, year) VALUES ('#{name}', '#{link}', '#{description}', '#{topic}', '#{year}')"
    self.run(sql)
  end
end
