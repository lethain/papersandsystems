require 'mysql2'
require './utils'


class Systems < PASModel
  def initialize(mysql)
    super(mysql, 'systems')
  end
end

