require 'mysql2'
require './utils'


class Users < PASModel
  def initialize(mysql)
    super(mysql, 'users')
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
      existing = self.get_by_id(id)
      if existing
        sql = "UPDATE #{@table} SET access_token='#{access_token}', login='#{login}', avatar='#{avatar}', email='#{email}' WHERE id=#{id}"
        results = self.run(sql)
      else
        sql = "INSERT INTO #{@table} (id, access_token, login, avatar, email) VALUES ('#{id}', '#{access_token}', '#{login}', '#{avatar}', '#{login}')"
        results = self.run(sql)
      end
    end
    return results, success
  end

  def get_by_id(id)
    id = self.escape(id)
    sql = "SELECT * FROM #{@table} WHERE id=#{id} LIMIT 1"
    results = self.run(sql)
    results.size > 0 ? results.first : nil
  end

  def get_by_token(access_token)
    if access_token
      access_token = self.escape(access_token)
      sql = "SELECT * FROM #{@table} WHERE access_token='#{access_token}' LIMIT 1"
      results = self.run(sql)
      results.size > 0 ? results.first : nil
    end
  end
end
