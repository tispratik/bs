class Task < ActiveRecord::Base

  default_scope :order => "deleted_at asc, updated_at desc"
    
  TYPES = Decode.find_all_by_name("BS_Task_Type")
  PRIORITIES = Decode.find_all_by_name("BS_Task_Priority")

  has_many :comments, :as => :commentable, :dependent => :destroy
  belongs_to :project
  belongs_to :initiator, :class_name => 'User', :foreign_key => "created_by"
  belongs_to :updator, :class_name => 'User', :foreign_key => "updated_by"
  belongs_to :assignee, :class_name => 'User', :foreign_key => "assign_to"  
  belongs_to :priorityDecode, :class_name => 'Decode', :foreign_key => "priority"
  belongs_to :statusDecode, :class_name => 'Decode', :foreign_key => "status"
  named_scope :deleted, { :conditions => ['deleted_at != ?', nil] }

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