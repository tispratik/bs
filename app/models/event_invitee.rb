class EventInvitee < ActiveRecord::Base
  belongs_to :user
  belongs_to :event
  
  validates_presence_of :event, :user_email
end