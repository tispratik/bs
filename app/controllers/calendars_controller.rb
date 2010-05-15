class CalendarsController < ApplicationController
  
  before_filter :find_calendarable
  
  def index
    @calendars = current_user.calendars
  end
  
  def new
    @calendar = current_user.calendars.new
  end
  
  def create
    @calendar = current_user.calendars.new(params[:calendar])
    
    begin
      if @calendar.save
        flash[:notice] = "Created new calendar."
      else
        raise
      end
    rescue
      flash[:error] = "Error parsing calendar from url."
    end
    redirect_to [@calendarable, :events]
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
  
end