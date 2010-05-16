class Timesheet < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  has_many :timelogs
end