class Timesheet < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :objectable
  has_many :timelogs, :dependent => :destroy
  
  validates_presence_of :user, :project, :description
end