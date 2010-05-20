class AlertsController < ApplicationController
  
  before_filter :find_project
  
  def index
    @count = '100'
    @learnmore = "Every change in the project creates an alert."
  end
  
end
