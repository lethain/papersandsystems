require 'mysql2'
require './utils'


class Systems < PASModel
  def initialize(mysql)
    super(mysql, 'systems')
  end

  def get_by_template_or_id(segment)
    if segment.length == 36
      self.get('id', segment)
    else
      self.get('template', segment)
    end
  end

  def create(name, template)
    id = self.uuid
    pos = self.count() + 1
    name, template = [name, template].map { |x| self.escape(x) }
    sql = "INSERT INTO #{@table} (id, pos, name, template) VALUES ('#{id}', '#{pos}', '#{name}', '#{template}')"
    self.run(sql)
  end
  
end
