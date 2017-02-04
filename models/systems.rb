require 'mysql2'
require './utils'

# Systems model
class Systems < PASModel
  def initialize(mysql)
    super(mysql, 'systems')
  end

  def get_by_template_or_id(segment)
    if segment.length == 36
      get('id', segment)
    else
      get('template', segment)
    end
  end

  def create(name, template)
    id = uuid
    pos = count + 1
    name, template = [name, template].map { |x| escape(x) }
    sql = "INSERT INTO #{@table} (id, pos, name, template) VALUES ('#{id}', '#{pos}', '#{name}', '#{template}')"
    run(sql)
  end
end
