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

  def list(opts=nil)
    opts = opts ? opts : {}
    sort = opts[:sort] ? opts[:sort] : 'id'
    sql = "SELECT * FROM #{@table}"
    sql += " ORDER BY #{sort}"
    if opts[:limit]
      sql += " LIMIT #{opts[:limit]}"
    end
    self.run(sql)
  end

  def count
    key = 'COUNT(id)'
    sql = "SELECT #{key} FROM #{@table}"
    res = self.run(sql).to_a
    if res.size and res[0].has_key?(key)
      res[0]['COUNT(id)']
    else
      0
    end
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
