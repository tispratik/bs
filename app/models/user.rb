class User < ActiveRecord::Base
  
  establish_connection "va_#{RAILS_ENV}"
  
  has_one :usr
  has_one :ucontact
  has_many :project_roles
  has_many :projects, :through => :project_roles
  has_many :tasks, :through => :projects
  has_many :ac_proj_op_tasks, :through => :projects, :source => :tasks, :conditions => "projects.status = #{Decode::BS_PROJ_STATUS_AC} AND tasks.status=#{Decode::BS_TASK_STATUS_OP}"
  has_many :calendars, :as => :calendarable
  has_many :events, :through => :calendars
  has_many :project_invitations
  has_many :articles
  
  alias :roles :project_roles
  accepts_nested_attributes_for :usr, :ucontact
  
  validates_presence_of :login_email, :username
  validates_associated :usr, :ucontact
  validates_wholesomeness_of :username, :if => lambda{|user| user.username.present? }

  def validate
    validate_login_email
  end
  
  def validate_login_email
    unless EmailVeracity::Address.new(login_email).valid?
      errors.add(:login_email, "is invalid")
    end
  end
  
  acts_as_authentic do |a|
    a.logged_in_timeout = 100.minutes # default is 10.minutes
    a.validates_format_of_login_field_options :with => /^\w+$/, :message => "only numbers, letters and underscore allowed"
  end
  
  def self.find_by_username_or_login_email(login)
    find_by_username(login) || find_by_login_email(login)
  end
  
  def my_projects_with_roles
    ProjectRole.all(:conditions => {:user_id => id}, :include => :project)
  end
  
  def calendar
    calendars.first
  end
  
  def to_param
    username
  end
  
  def to_s
    [usr.first_name, usr.last_name].join(' ')
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
  
  def self.cid
    User.curr_user.id
  end
  
end