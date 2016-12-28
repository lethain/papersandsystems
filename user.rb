require 'mongo'

def users_db
  client = Mongo::Client.new('mongodb://127.0.0.1:27017/users')
  db = client.database
  client[:users]
end

def get_user(access_token)
  if access_token
    udb = users_db
    udb.find({access_token: access_token}).first
  end
end

# create user from github /user and /user/emails responses
def create_user(access_token, user, emails)
  doc = {
    id: user['id'],
    access_token: access_token,
    login: user['login'],
    avatar: user['avatar_url'],
    email: nil
  }
  emails.each do |x|
    if x['verified'] and x['primary']
      doc[:email] = x['email']
      break
    end
  end
  success = doc[:email] != nil

  puts "success: #{success}"

  if success
    udb = users_db
    existing = udb.find({id: user['id']}).first
    puts "exisitng: #{existing}"
    if existing
      udb.update_one({id: user['id']}, {'$set': {access_token: access_token}})
    else
      udb.insert_one(doc)
    end
  end
  return doc, success
end
