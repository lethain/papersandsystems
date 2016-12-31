require './utils'


class UserSystems < PASModel
  def initialize(mysql)
    super(mysql, 'user_systems')
  end

  def user_count(user_id)
    self.count(:user_id => user_id)
  end

  def create(user_id, system_id)
    sql = "INSERT INTO #{@table} (user_id, system_id) VALUES ('#{user_id}', '#{system_id}')"
    self.run(sql)
  end

  def has_completed(user_id, system_id)
    key = 'ts'
    sql = "SELECT #{key} FROM #{@table} WHERE user_id='#{user_id}' AND system_id='#{system_id}'"
    res = self.run(sql).to_a
    if res.size > 0 and res[0].has_key?(key)
      res[0][key]
    else
      nil
    end
  end
  
end
