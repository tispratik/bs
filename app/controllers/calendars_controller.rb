class CalendarsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_calendarable
  
  def index
    @calendars = current_user.calendars
  end
  
  def new
    @calendar = current_user.calendars.new
  end
  
  def create
    @calendar = current_user.calendars.new(params[:calendar])
    
    if @calendar.save
      flash[:notice] = "Created new calendar."
      redirect_to [@calendarable, :events]
    else
      render :action => :new
    end
  end
  
  def destroy
    @calendar = @calendarable.calendars.find(params[:id])
    unless @calendar.name == "default"
      @calendar.destroy
      flash[:notice] = "Calendar removed."
    else
      flash[:notice] = "You can't remove default calendar."
    end
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