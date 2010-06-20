class Expense < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :objectable
  has_many :expenselogs, :dependent => :destroy
  
  validates_presence_of :user, :project, :description
end