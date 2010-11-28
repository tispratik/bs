class Timelog < ActiveRecord::Base
  
  belongs_to :timesheet
  belongs_to :project
  
  attr_accessor :timesheet_description
  
  validates_presence_of :timesheet, :project, :hours, :date, :timesheet_description
  before_validation :run_before_validation, :on => :create
  
  def run_before_validation
    if timesheet_description.present?
      #find or create new timesheet
      self.timesheet = project.timesheets.find_by_user_id_and_description(User.curr_user.id, timesheet_description)
      unless timesheet
        self.timesheet = project.timesheets.build(:user_id => User.curr_user.id, :description => timesheet_description)
      end
    end
  end
  
end