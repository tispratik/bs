class Expenselog < ActiveRecord::Base
  
  belongs_to :expense
  belongs_to :project
  
  attr_accessor :expense_description
  
  validates_presence_of :expense, :project, :amount, :date, :expense_description
  before_validation :run_before_validation, :on => :create
  
  def run_before_validation
    if expense_description.present?
      #find or create new timesheet
      self.expense = project.expenses.find_by_user_id_and_description(User.curr_user.id, expense_description)
      unless expense
        self.expense = project.expenses.build(:user_id => User.curr_user.id, :description => expense_description)
      end
    end
  end
  
end