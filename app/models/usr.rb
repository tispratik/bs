class Usr < ActiveRecord::Base
  establish_connection "op_#{Rails.env}"
  belongs_to :user
  
  validates_presence_of :first_name, :last_name
  
end