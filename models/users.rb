require 'mysql2'
require './utils'

# Users model
class Users < PASModel
  def initialize(mysql)
    super(mysql, 'users')
  end

  def create(access_token, user, emails)
    id = escape(user['id'])
    access_token = escape(access_token)
    login = escape(user['login'])
    avatar = escape(user['avatar_url'])
    email = nil
    emails.each do |x|
      if x['verified'] && x['primary']
        email = escape(x['email'])
        break
      end
    end

    success = !email.nil?
    results = nil
    if success
      existing = get_by_id(id)
      sql = if existing
              "UPDATE #{@table} SET access_token='#{access_token}', login='#{login}', avatar='#{avatar}', email='#{email}' WHERE id=#{id}"
            else
              "INSERT INTO #{@table} (id, access_token, login, avatar, email) VALUES ('#{id}', '#{access_token}', '#{login}', '#{avatar}', '#{email}')"
            end
      results = run(sql)
    end
    [results, success]
  end

  def get_by_id(id)
    get('id', id)
  end

  def get_by_token(access_token)
    get('access_token', access_token)
  end
end
