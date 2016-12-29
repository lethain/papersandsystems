require 'mysql2'
require './utils'


class Systems < PASModel
  def initialize(mysql)
    super(mysql, 'systems')
  end
  
  def list
    sql = "SELECT * FROM #{@table} ORDER BY id"
    self.run(sql)    
  end


end

