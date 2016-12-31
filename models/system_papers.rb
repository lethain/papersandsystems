require './utils'

class SystemPapers < PASModel
  def initialize(mysql)
    super(mysql, 'system_papers')
  end

  def create(system_id, paper_id)
    sql = "INSERT INTO #{@table} (system_id, paper_id) VALUES ('#{system_id}', '#{paper_id}')"
    self.run(sql)
  end

  def related_systems(paper_id)
    paper_id = self.escape(paper_id)
    sql = "SELECT systems.id, systems.name, systems.completion_count FROM system_papers JOIN systems ON systems.id=system_papers.system_id WHERE paper_id='#{paper_id}' ORDER BY systems.id"
    self.run(sql)
  end

  def related_papers(system_id)
    system_id = self.escape(system_id)
    sql = "SELECT papers.id, papers.name, papers.read_count FROM system_papers JOIN papers ON papers.id=system_papers.paper_id WHERE system_id='#{system_id}' ORDER BY papers.id"
    self.run(sql)
  end

  def bulk_create(paper_id, system_ids)
    system_ids.each do |system_id|
      self.create(system_id, paper_id)
    end
  end

end
