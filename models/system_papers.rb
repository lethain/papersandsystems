require './utils'

class SystemPapers < PASModel
  def initialize(mysql)
    super(mysql, 'system_papers')
  end

  def create(system_id, paper_id)
    sql = "INSERT INTO #{@table} (system_id, paper_id) VALUES ('#{system_id}', '#{paper_id}')"
    self.run(sql)
  end

  def bulk_create(paper_id, system_ids)
    system_ids.each do |system_id|
      self.create(system_id, paper_id)
    end
  end

end
