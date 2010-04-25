class CalendarsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_calendarable
  
  def show
    respond_to do |format|
      format.html do
        @month = (params[:month] || Time.zone.now.month).to_i
        @year = (params[:year] || Time.zone.now.year).to_i
        
        @shown_month = Date.civil(@year, @month)
        @event_strips = @calendarable.calendar.events.event_strips_for_month(@shown_month)
      end
      format.ical do
        @ical = RiCal.Calendar do |cal|
          @calendarable.calendar.events.each do |event|
            cal.event do
              summary   event.name
              dtstart   event.start_at
              dtend     event.end_at
            end
          end
        end
        render :text => @ical
      end
    end
  end
  
  def create
    begin
      @ical = RiCal.parse(params[:ical_file]).first
      
      Event.transaction do
        @calendar = @calendarable.calendars.create(:name => @ical.x_properties["X-WR-CALNAME"].first.value)
        @ical.events.each do |event|
          Event.create(
            :calendar => @calendar,
            :summary => event.summary,
            :start_at => event.dtstart,
            :end_at => event.dtend
          )
        end
      end
      flash[:notice] = "Created new calendar."
    rescue
      flash[:error] = "Error opening file."
    ensure
      redirect_to [@calendarable, :events]
    end
  end
  
  def destroy
    @calendar = Calendar.find(params[:id])
    @calendar.destroy
    flash[:notice] = "Calendar removed."
    redirect_to [@calendar.calendarable, :events]
  end
  
  def find_calendarable
    if params[:project_id]
      @calendarable = @project = Project.find_by_permalink(params[:project_id])
    elsif params[:user_id]
      @calendarable = @user = User.find_by_username(params[:user_id])
    else
      @calendarable = @user = current_user
    end
  end
  
end