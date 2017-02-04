require 'mysql2'
require './utils'

class Papers < PASModel
  def initialize(mysql)
    super(mysql, 'papers')
  end

  def create(name, link, description, topic, year, slug)
    id = uuid
    pos = count + 1
    name, link, description, topic, year, slug = [name, link, description, topic, year, slug].map { |x| escape(x) }
    sql = "INSERT INTO #{@table} (id, pos, name, link, description, topic, year, slug) VALUES ('#{id}', '#{pos}', '#{name}', '#{link}', '#{description}', '#{topic}', '#{year}', '#{slug}')"
    run(sql)
  end
end
