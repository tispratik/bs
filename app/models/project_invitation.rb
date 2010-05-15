class ProjectInvitation < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  
  validates_presence_of :project, :user_email
  validates_uniqueness_of :user_id, :scope => :project_id, :unless => "user_id.nil?"
  
  def after_create
    if user.present?
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
  end
end
