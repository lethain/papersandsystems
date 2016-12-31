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
    self.log(sql, results)
    results
  end

  def get(col, val, fields=nil)
    if val
      val = self.escape(val)
      fields = fields ? fields.join(', ') : '*'
      sql = "SELECT #{fields} FROM #{@table} WHERE #{col}='#{val}' LIMIT 1"
      results = self.run(sql)
      results.size > 0 ? results.first : nil
    end
  end

  def list(opts=nil)
    opts = opts ? opts : {}
    sort = opts[:sort] ? opts[:sort] : 'id'
    cols = opts[:cols] ? opts[:cols].join(", ") : '*'
    sql = "SELECT #{cols} FROM #{@table}"
    if opts[:where]
      filters = opts[:where].map do |k,v|
        "#{k}='#{self.escape(v)}'"
      end
      sql += " WHERE #{filters.join(' and ')}"
    end
    sql += " ORDER BY #{sort}"    
    if opts[:limit]
      sql += " LIMIT #{opts[:limit]}"
    end
    puts "SQL: #{sql}"
    self.run(sql)
  end

  def update(id, kvs)
    sql = "UPDATE #{@table} SET"
    kvs.each_pair do |k, v|
      sql += " #{k}='#{self.escape(v)}'"
    end
    sql += " WHERE id='#{self.escape(id)}'"
    self.run(sql)
  end

  def incr(id, key)
    sql = "UPDATE #{@table} SET #{key} = #{key} + 1 WHERE id='#{self.escape(id)}'"
    self.run(sql)
  end

  def count(opts=nil)
    opts = opts ? opts : {}    
    key = 'COUNT(id)'
    sql = "SELECT #{key} FROM #{@table}"
    if opts[:where]
      filters = opts[:where].map do |k,v|
        "#{k}='#{self.escape(v)}'"
      end
      sql += " WHERE #{filters.join(' and ')}"
    end
    
    res = self.run(sql).to_a
    if res.size and res[0].has_key?(key)
      res[0][key]
    else
      0
    end
  end

  def log(sql, results)
    @log.info("'#{sql}', #{results.to_a}")
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
