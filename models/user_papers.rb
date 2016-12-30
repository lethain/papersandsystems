require './utils'


class UserPapers < PASModel
  def initialize(mysql)
    super(mysql, 'user_papers')
  end

  def create(user_id, paper_id)
    sql = "INSERT INTO #{@table} (user_id, paper_id) VALUES ('#{user_id}', '#{paper_id}')"
    self.run(sql)
  end

  def user_count(user_id)
    self.count(:user_id => user_id)
  end

  def has_read(user_id, paper_id)
    key = 'ts'
    sql = "SELECT #{key} FROM #{@table} WHERE user_id='#{user_id}' and paper_id='#{paper_id}'"
    res = self.run(sql).to_a
    puts "has_read: #{res}"
    if res.size > 0 and res[0].has_key?(key)
      res[0][key]
    else
      nil
    end    
  end

end