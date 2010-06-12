class Consumption < ActiveRecord::Base  
  belongs_to :project
  BS_CONSP = Decode.find_all_by_name("BS_Consp")
  belongs_to :paramDecode, :class_name => 'Decode', :foreign_key => "paramname"
  
  def self.on_create_project(project_id)
    BS_CONSP.each do |c|
      con = Consumption.new
      con.project_id = project_id
      con.paramname = c.id
      con.count = 0
      con.created_at = Date.today
      con.updated_at = Date.today
      con.save
    end
  end
  
  def self.add(project_id, paramname, count)
    d = Decode.find_by_constant_value(paramname)
    c = find_by_project_id_and_paramname(project_id, d.id)
    c.count = c.count + count.to_i()
    c.save
  end
  
  def self.sub(project_id, paramname, count)
    d = Decode.find_by_constant_value(paramname)
    c = find_by_project_id_and_paramname(project_id, d.id)
    if c.count.to_i() > 0
      c.count = c.count - count.to_i()
      c.save
    end
  end
    
  def self.get(project_id, paramname)
    d = Decode.find_by_constant_value(paramname)
    c = find_by_project_id_and_paramname(project_id, d.id)
    return c.count
  end

end