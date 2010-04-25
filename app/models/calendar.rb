class Calendar < ActiveRecord::Base
  
  belongs_to :calendarable, :polymorphic => true
  has_many :events
  
  def user
    (calendarable.is_a?(User)) ? calendarable : calendarable.user
  end
end
