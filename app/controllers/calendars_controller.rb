class CalendarsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_calendarable
  
  def index
    @calendars = current_user.calendars
  end
  
  def create
    @calendar = current_user.calendars.new(params[:calendar])
    
    begin
      @calendar.save
      flash[:notice] = "Created new calendar."
      redirect_to [@calendarable, :events]
    end
  end
  
  def destroy
    @calendar = current_user.calendars.find(params[:id])
    @calendar.destroy
    flash[:notice] = "Calendar removed."
    redirect_to [@calendar.calendarable, :events]
  end
  
  def find_calendarable
    if params[:project_id]
      find_project
      @calendarable = @project
    elsif params[:user_id]
      @calendarable = @user = User.find_by_username(params[:user_id])
    else
      @calendarable = @user = current_user
    end
  end
  
end