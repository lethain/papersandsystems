require 'mysql2'
require './utils'


class Systems < PASModel
  def initialize(mysql)
    super(mysql, 'systems')
  end

  def create(name, template)
    name, template = [name, template].map { |x| self.escape(x) }
    sql = "INSERT INTO #{@table} (name, template) VALUES ('#{name}', '#{template}')"
    self.run(sql)
  end
end
