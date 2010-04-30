class Task < ActiveRecord::Base
  
  TYPES = Decode.find_all_by_name("BS_Task_Type")
  PRIORITIES = Decode.find_all_by_name("BS_Task_Priority")
  STATUSES = Decode.find_all_by_name_and_is_active("BS_Task_Status", 1)

  has_many :comments, :as => :commentable, :dependent => :destroy
  belongs_to :project
  belongs_to :type_val, :class_name => 'Decode', :foreign_key => "task_type"
  belongs_to :priorityDecode, :class_name => 'Decode', :foreign_key => "priority"
  belongs_to :statusDecode, :class_name => 'Decode', :foreign_key => "status"
  belongs_to :initiator, :class_name => 'User', :foreign_key => "created_by"
  belongs_to :updator, :class_name => 'User', :foreign_key => "updated_by"
  belongs_to :assignee, :class_name => 'User', :foreign_key => "assign_to"  
  named_scope :ai, :conditions => { :task_type => Decode::BS_TASK_TYPE_AI }
  named_scope :oi, :conditions => { :task_type => Decode::BS_TASK_TYPE_OI }
  named_scope :open, :conditions => { :status => Decode::BS_TASK_STATUS_OP }
  named_scope :completed, :conditions => { :status => Decode::BS_TASK_STATUS_CO }
  named_scope :active_project, :conditions => "projects.status = 1"

  validates_presence_of :name, :assign_to, :task_type, :priority 
  
  def priority_image
    case priority
      when Decode::BS_TASK_PRIORITY_ME; "medium.jpg"
      when Decode::BS_TASK_PRIORITY_HI; "high.png"
    else "low.jpg"
    end
  end
  
  def type_image
    if task_type == Decode::BS_TASK_TYPE_OI
      return "openissue.png"
    end
    return "task.ico"
  end
  
  def to_s
    name
  end
  
  def before_validation
    self.created_by = User.curr_user.id
    self.updated_by = User.curr_user.id
    self.status = Decode::BS_TASK_STATUS_OP
    self.task_type = Decode::BS_TASK_TYPE_AI
  end
  
  def before_create
    self.alias = 'TASK' + id.to_s() 
  end
end