require 'mysql2'
require './utils'


class Users
  def initialize(mysql)
    @table = 'users'
    @m = mysql
    @log = get_logger
  end

  def escape(val)
    if val.is_a? Integer
      val
    else
      @m.escape(val)
    end
  end

  def create(access_token, user, emails)
    id = self.escape(user['id'])
    access_token = self.escape(access_token)
    login = self.escape(user['login'])
    avatar = self.escape(user['avatar_url'])
    email = nil
    emails.each do |x|
      if x['verified'] and x['primary']
        email = self.escape(x['email'])
        break
      end
    end

    success = email != nil
    results = nil
    if success
      existing = self.get_by_id(id).size == 1
      if existing
        sql = "UPDATE #{@table} SET access_token='#{access_token}', login='#{login}', avatar='#{avatar}', email='#{email}' WHERE id=#{id}"
        results = @m.query(sql)
        @log.info("update: '#{sql}', #{results.to_a}")
      else
        sql = "INSERT INTO #{@table} (id, access_token, login, avatar, email) VALUES ('#{id}', '#{access_token}', '#{login}', '#{avatar}', '#{login}')"
        results = @m.query(sql)
        @log.info("create: '#{sql}', #{results.to_a}")
      end
    end
    return results, success
  end

  def list
    sql = "SELECT * FROM #{@table} ORDER BY id"
    results = @m.query(sql)
    @log.info("list: '#{sql}', #{results}")
    results
  end

  def get_by_id(id)
    id = self.escape(id)
    sql = "SELECT * FROM #{@table} WHERE id=#{id}"
    results = @m.query(sql)
    @log.info("get_by_id: '#{sql}', #{results.to_a}")
    results
  end

  def get_by_token(access_token)
    if access_token
      access_token = self.escape(access_token)
      sql = "SELECT * FROM #{@table} WHERE access_token='#{access_token}'"
      results = @m.query(sql)
      @log.info("get_by_token: '#{sql}', #{results.to_a}")
      results
    end
  end

end
