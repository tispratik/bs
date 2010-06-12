class Project < ActiveRecord::Base
  
  STATUSES = Decode.find_all_by_name("BS_Proj_Status")
  
  has_many :project_logos
  has_one :contact, :as => :contactable
  has_many :project_roles, :dependent => :destroy
  has_many :users, :through => :project_roles
  has_many :tasks
  has_many :alerts
  has_many :timesheets
  has_one :calendar, :as => :calendarable
  has_many :calendars, :as => :calendarable
  has_many :events, :through => :calendars
  has_many :wiki_pages
  has_many :articles
  has_many :assets, :as => :attachable
  has_many :tags
  has_many :timesheets
  has_many :consumptions
  has_many :timelogs
  belongs_to :statusDecode, :class_name => 'Decode', :foreign_key => "status"
  
  has_many :project_invitations
  alias :invitations :project_invitations
  alias :roles :project_roles
  
  accepts_nested_attributes_for :assets
  
  validates_presence_of :name, :permalink, :status
  validates_uniqueness_of :permalink
  
  def owner
    p = ProjectRole.find_by_project_id_and_name(id, "O")
    return p.user
  end
  
  def getnotify(userid)
    Notification.find_by_project_id_and_user_id(id, userid)
  end
  
  def is_archieved?
    if status == Decode::BS_PROJ_STATUS_CL
      return true
    else
      return false
    end
  end
  
  def before_validation_on_create
    self.alias = 'PROJ' + id.to_s
    self.is_public = 0
    self.status = Decode::BS_PROJ_STATUS_AC
    self.permalink = Authlogic::Random.friendly_token
  end
  
  def after_create
    calendars.create(:name => "default")
    #Make owner of project when created
    roles.create(:user => User.curr_user)
  end
  
  def calendar
    calendars.first
  end
  
  def to_s
    name
  end
  
  def to_param
    UrlStore.encode(permalink)
  end
  
  def status_val
    statusDecode.display_value
  end
  
  def self.current_project
    Thread.current[:current_project]
  end
  
  def self.current_project=(project)
    #Setting the project to nil on logout
    #    raise(ArgumentError,
    #          "Invalid project. Expected an object of class 'Project', got #{project.inspect}") unless project.is_a?(Project)
    Thread.current[:current_project] = project
  end
end