class Task < ActiveRecord::Base
  
  TYPES = Decode.find_all_by_name("Task_Type")
  PRIORITIES = Decode.find_all_by_name("Task_Priority")
  STATUSES = Decode.find_all_by_name("Task_Status")
  
  has_many :comments, :as => :commentable
  
  validates_presence_of :assign_to, :task_type, :priority, :task_type
  
  belongs_to :type_val, :class_name => 'Decode', :foreign_key => "task_type"
  belongs_to :priorityDecode, :class_name => 'Decode', :foreign_key => "priority"
  belongs_to :project
  belongs_to :statusDecode, :class_name => 'Decode', :foreign_key => "status"
  
  named_scope :ai, :conditions => { :task_type => Decode::TASK_TYPE_AI }
  named_scope :oi, :conditions => { :task_type => Decode::TASK_TYPE_OI }
  named_scope :open, :conditions => { :status => Decode::TASK_STATUS_OPEN }
  #scope_procedure :open, lambda { status_eq(Decode::TASK_STATUS_OPEN) }
  named_scope :completed, :conditions => { :status => Decode::TASK_STATUS_COMPLETED }
  #scope_procedure :active_project, lambda { project_status_eq(Decode::PROJECT_STATUS_ACTIVE) }
  named_scope :active_project, :conditions => "projects.status = 1"
  belongs_to :initiator, :class_name => 'User', :foreign_key => "created_by"
  belongs_to :updator, :class_name => 'User', :foreign_key => "updated_by"
  belongs_to :assignee, :class_name => 'User', :foreign_key => "assign_to"
  
  def priority_image
    case priority
      when Decode::TASK_PRIORITY_MED; "medium.jpg"
      when Decode::TASK_PRIORITY_HIGH; "high.png"
    else "low.jpg"
    end
  end
  
  def type_image
    if task_type == Decode::TASK_TYPE_OI
      return "openissue.png"
    end
    return "task.ico"
  end
  
  def to_s
    name
  end
  
  def status_val
    statusDecode.display_value
  end
  
  def before_validation_on_create
    self.status = Decode::TASK_STATUS_OPEN
    self.created_by = User.curr_user.id
    self.updated_by = User.curr_user.id
  end
  
  def before_create
    self.alias = 'TASK' + id.to_s() 
  end
end