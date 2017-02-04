require './utils'

# UserPapers model
class UserPapers < PASModel
  def initialize(mysql)
    super(mysql, 'user_papers')
  end

  def create(user_id, paper_id, rating)
    sql = "INSERT INTO #{@table} (user_id, paper_id, rating) VALUES ('#{user_id}', '#{paper_id}', '#{rating}')"
    run(sql)
  end

  def user_count(user_id)
    count(where: { user_id: user_id })
  end

  def rating(pid)
    pid = escape(pid)
    key = 'AVG(rating)'
    sql = "SELECT #{key} FROM #{@table} WHERE paper_id='#{pid}'"
    res = run(sql).to_a
    if !res.empty? && res[0].key?(key)
      res[0][key]
    else
      0
    end
  end

  def mark_read(user_id, papers)
    return papers if papers.empty?

    pids = papers.map { |x| escape(x['id']) }
    as_str = pids.map { |x| "'#{x}'" }
    as_str = as_str.join(',')
    sql = "SELECT paper_id, ts FROM #{@table} WHERE user_id='#{user_id}' AND paper_id IN (#{as_str})"
    res = run(sql)
    ts = {}
    res.each do |row|
      ts[row['paper_id']] = row['ts']
    end
    papers.each do |paper|
      paper['user_has_read'] = ts[paper['id']]
    end
    papers
  end

  def read?(user_id, paper_id)
    key = 'ts'
    sql = "SELECT #{key} FROM #{@table} WHERE user_id='#{user_id}' AND paper_id='#{paper_id}'"
    res = run(sql).to_a
    res[0][key] if !res.empty? && res[0].key?(key)
  end
end
