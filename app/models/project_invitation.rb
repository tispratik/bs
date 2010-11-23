class ProjectInvitation < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  
  validates_presence_of :project, :user_email
  
  before_create :create_sha_token
  after_create :create_calendar_event
  
  def create_sha_token
    self.token = Digest::SHA1.hexdigest "#{Time.now.to_i}-#{rand(10**10)}"
  end
  
  def create_calendar_event
    if user.present? && user.calendar.present?
      user.calendar.events.create(:summary => "Invitation to project #{project}", :start_at => Time.now, :end_at => Time.now)
    end
  end
  
  def invitee=(name)
    self.user = User.find_by_username_or_login_email(name)
    self.user_email = user.present? ? user.login_email : name
  end
  
  def invitee
    user
  end
  
  def confirm
    update_attribute(:confirmed, true)
    ProjectRole.create(:project => project, :user => user, :name => "Collaborator")
    Notification.create(:project => project, :user => user)
  end
  
  def to_param
    token
  end
end
