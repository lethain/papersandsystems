require 'logger'

def get_logger
  Logger.new(STDERR)
end



class PASModel
  def initialize(mysql, table)
    @table = table
    @m = mysql
    @log = get_logger
  end

  def run(sql)
    results = @m.query(sql)
    self.log('create', sql, results)
    results
  end

  def log(op, sql, results)
    @log.info("#{op}: '#{sql}', #{results.to_a}")    
  end

  def escape(val)
    if val.is_a? Integer
      val
    else
      @m.escape(val)
    end
  end  

  def standard(s)
    @m.escape(s.gsub(/\W+/, ' ').strip)
  end

end
