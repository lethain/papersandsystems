require './utils'


class UserPapers < PASModel
  def initialize(mysql)
    super(mysql, 'user_papers')
  end

  def create(user_id, paper_id, rating)
    sql = "INSERT INTO #{@table} (user_id, paper_id, rating) VALUES ('#{user_id}', '#{paper_id}', '#{rating}')"
    self.run(sql)
  end

  def user_count(user_id)
    self.count(:user_id => user_id)
  end

  def rating(pid)
    pid = self.escape(pid)
    key = 'AVG(rating)'    
    sql = "SELECT #{key} FROM #{@table} WHERE paper_id='#{pid}'"
    res = self.run(sql).to_a
    if res.size > 0 and res[0].has_key?(key)
      res[0][key]
    else
      0
    end
  end

  def mark_read(user_id, papers)
    return papers if papers.size == 0
    
    pids = papers.map { |x| self.escape(x['id']) }
    sql = "SELECT paper_id, ts FROM #{@table} WHERE user_id='#{user_id}' AND paper_id IN (#{pids.join(',')})"
    res = self.run(sql)
    ts = {}
    res.each do |row|
      ts[row['paper_id']] = row['ts']
    end
    papers.each do |paper|
      paper['user_has_read'] = ts[paper['id']]
    end
    papers
  end

  def has_read(user_id, paper_id)
    key = 'ts'
    sql = "SELECT #{key} FROM #{@table} WHERE user_id='#{user_id}' AND paper_id='#{paper_id}'"
    res = self.run(sql).to_a
    if res.size > 0 and res[0].has_key?(key)
      res[0][key]
    else
      nil
    end
  end

end
