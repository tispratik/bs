class Project < ActiveRecord::Base
  
  STATUSES = Decode.find_all_by_name("Project_Status")
  
  has_one :contact, :as => :contactable
  has_many :project_roles
  has_many :users, :through => :project_roles
  has_many :tasks
  has_one :calendar, :as => :calendarable
  has_many :wiki_pages
  has_many :articles
  has_many :assets, :as => :attachable
  has_many :tags
  belongs_to :statusDecode, :class_name => 'Decode', :foreign_key => "status"
  
  has_many :project_invitations
  alias :invitations :project_invitations
  alias :roles :project_roles
  
  validates_presence_of :name, :permalink, :status
  validates_uniqueness_of :permalink
  
  def before_validation_on_create
    self.alias = 'PROJ' + id.to_s
    self.is_public = 0
    self.status = Decode::PROJECT_STATUS_ACTIVE
    self.permalink = Authlogic::Random.friendly_token
  end
  
  def after_create
    self.calendar = Calendar.create(:name => "default")
    #Make owner of project when created
    r = self.roles.build
    r.user = User.curr_user
    r.save
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