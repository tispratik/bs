class AlertsController < ApplicationController
  
  before_filter :find_project
  
  def index
    @count = '100'
  end
  
end
