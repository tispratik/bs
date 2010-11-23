class ProjectRole < ActiveRecord::Base
  
  set_table_name "bs_#{Rails.env}" + ".project_roles"
  belongs_to :project
  belongs_to :user
  
  validates_presence_of :project, :user, :name

  before_validation :set_name
  
  def to_name
    if self.name == "O"
      return "Owner"
    end
    if self.name == "C"
      return "Collaborator"
    end
  end
  
  def set_name
    self.name ||= 'O'
  end
end
