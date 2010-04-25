class ProjectInvitation < ActiveRecord::Base
  belongs_to :project
  belongs_to :user
  
  validates_presence_of :project, :user
  validates_uniqueness_of :user_id, :scope => :project_id
  
  def after_create
    user.calendar.events.create(:summary => "Invitation to project #{project}", :start_at => Time.now, :end_at => Time.now)
  end
  
  def invitee=(name)
    self.user = User.username_or_email_is(name).first
  end
  
  def invitee
    user
  end
  
  def confirm
    update_attribute(:confirmed, true)
    ProjectRole.create(:project => project, :user => user, :name => "Collaborator")
  end
end
