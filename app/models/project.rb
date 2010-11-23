class Project < ActiveRecord::Base
  
  STATUSES = Decode.find_all_by_name("BS_Proj_Status")
  
  has_one :project_logo
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
  has_many :timelogs
  has_many :expenses
  has_many :expenselogs
  has_many :consumptions
  belongs_to :statusDecode, :class_name => 'Decode', :foreign_key => "status"
  belongs_to :currency, :class_name => 'Country', :foreign_key => "currency_code"
  
  has_many :project_invitations
  alias :invitations :project_invitations
  alias :roles :project_roles
  
  accepts_nested_attributes_for :assets
  #accepts_nested_attributes_for :project_logo
  
  validates_presence_of :name, :permalink, :status
  validates_uniqueness_of :permalink
    
  after_create :create_calendar_for_project, :make_project_owner
  
  def owner
    p = ProjectRole.find_by_project_id_and_name(id, "O")
    return p.user
  end
  
#  def currency_country
#    Country.find_by_id(currency_code)
#  end
  
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
  
  before_validation(:on => :create) do
    self.alias = 'PROJ' + id.to_s
    self.is_public = 0
    self.status = Decode::BS_PROJ_STATUS_AC
    self.permalink = Authlogic::Random.friendly_token
  end
  
  def create_calendar_for_project
    self.calendars.create(:name => "default")
  end
  
  def make_project_owner
    #Make owner of project when created
    self.roles.create(:user => User.curr_user, :name => "O")
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