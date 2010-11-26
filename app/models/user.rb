class User < ActiveRecord::Base
  
  establish_connection "va_#{Rails.env}"
  
  has_one :usr
  has_one :ucontact
  has_many :project_roles
  has_many :projects, :through => :project_roles
  has_many :tasks, :through => :projects
  has_many :alerts, :through => :projects 
  has_many :ac_proj_op_tasks, :through => :projects, :source => :tasks, :conditions => "projects.status = #{Decode::BS_PROJ_STATUS_AC} AND tasks.status=#{Decode::BS_TASK_STATUS_OP}"
  has_many :calendars, :as => :calendarable
  has_many :events, :through => :calendars
  has_many :project_invitations
  has_many :articles
  has_many :timesheets, :through => :projects 

  alias :roles :project_roles
  accepts_nested_attributes_for :usr, :ucontact
  
  validates :login_email, :username, :presence => true
  validates_associated :usr, :ucontact
  #validates_wholesomeness_of :username, :if => lambda{|user| user.username.present? } --> Name Nanny Plugin not available in Rails3
  validate :validate_login_email
  after_create :create_calendar, :create_project_invite, :create_event_invite
  
  def total_hours(pid)
    timesheetsvar = Timesheet.all(:conditions => { :project_id => pid, :user_id => id})
    totalhours = 0
    timesheetsvar.each do |t|
      t.timelogs.each do |tl|
        totalhours = totalhours + tl.hours
      end
    end
    return totalhours
  end
  
  def is_archieved?
    return false
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
  
  def create_calendar
    self.calendars.create :name => "default"
  end
  
  def create_project_invite
    # set current user_id for pending project and event invitations.
    self.project_invitations.create :user_email => login_email
  end
  
  def create_event_invite
    EventInvitee.create :user_id => id, :user_email => login_email
  end
  
  def my_projects_with_roles
    ProjectRole.where(:user_id => id).includes(:project)
  end
  
  def calendar
    calendars.first
  end
  
  def to_param
    username
  end
  
  def to_s
    [usr.first_name, usr.last_name[0,1]].join(' ') + "."
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
    curr_user.id
  end
  
end