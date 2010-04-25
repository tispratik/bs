class User < ActiveRecord::Base
  
  establish_connection :launchpad
  
  has_many :project_roles
  has_many :projects, :through => :project_roles
  has_many :tasks, :through => :projects
  has_many :ac_proj_op_tasks, :through => :projects, :source => :tasks, :conditions => "projects.status = #{Decode::PROJECT_STATUS_ACTIVE} AND tasks.status=#{Decode::TASK_STATUS_OPEN}"
  has_one :contact, :as => :contactable
  has_many :calendars, :as => :calendarable
  has_many :events, :through => :calendars
  has_many :project_invitations
  has_many :articles
  
  alias :roles :project_roles
  
  
  acts_as_authentic do |a|
    a.logged_in_timeout = 100.minutes # default is 10.minutes
    a.validates_format_of_login_field_options :with => /^\w+$/, :message =>"Only numbers, letters and underscore allowed"
  end
  
  def self.find_by_username_or_email(login)
    find_by_username(login) || first(:conditions => {:contacts => {:email => login}}, :joins => :contact)
  end
  
  def my_projects_with_roles
    # Project.all(:joins => "left join project_invitations on project_invitations.project_id=projects.id",
    #   :conditions => ["projects.user_id = ? or (project_invitations.user_id = ? and project_invitations.confirmed=1)", id, id],
    #   :group => "projects.id"
    # )
    ProjectRole.all(:conditions => {:user_id => id}, :include => :project)
  end
  
  def to_param
    username
  end
  
  def to_s
    [first_name, last_name].join(' ')
  end
  
  def self.curr_user
    Thread.current[:curr_user]
  end
  
  def self.curr_user=(user)
    #Setting the user to nil on logout
    #    raise(ArgumentError,
    #      "Invalid user. Expected an object of class 'User', got #{user.inspect}") unless user.is_a?(User)
    Thread.current[:curr_user] = user
  end
  
end