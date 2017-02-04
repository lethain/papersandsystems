require './utils'

class UserSystems < PASModel
  def initialize(mysql)
    super(mysql, 'user_systems')
  end

  def user_count(user_id)
    count(where: { user_id: user_id })
  end

  def create(user_id, system_id)
    sql = "INSERT INTO #{@table} (user_id, system_id) VALUES ('#{user_id}', '#{system_id}')"
    run(sql)
  end

  def mark_completed(user_id, systems)
    return systems if systems.empty?

    sids = systems.map { |x| escape(x['id']) }
    as_str = sids.map { |x| "'#{x}'" }
    as_str = as_str.join(',')
    sql = "SELECT system_id, ts FROM #{@table} WHERE user_id='#{user_id}' AND system_id IN (#{as_str})"
    res = run(sql)
    ts = {}
    res.each do |row|
      ts[row['system_id']] = row['ts']
    end
    systems.each do |system|
      system['user_has_completed'] = ts[system['id']]
    end
    systems
  end

  def has_completed(user_id, system_id)
    key = 'ts'
    sql = "SELECT #{key} FROM #{@table} WHERE user_id='#{user_id}' AND system_id='#{system_id}'"
    res = run(sql).to_a
    res[0][key] if !res.empty? && res[0].key?(key)
  end
end
