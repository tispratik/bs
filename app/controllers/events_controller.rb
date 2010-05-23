class EventsController < ApplicationController
  
  before_filter :find_calendarable
  before_filter :find_event, :except => [:index, :new, :create]
  
  def index
    @month = (params[:month] || Time.zone.now.month).to_i
    @year = (params[:year] || Time.zone.now.year).to_i
    @shown_month = Date.civil(@year, @month)
    
    if params[:user_ids]
      scope = Event.all_events_for_users(params[:user_ids])
      @displaying_events_for_users = true
    else
      if @calendarable.is_a?(User)
        scope = Event.all_events_for_users(@calendarable.id)
      else
        scope = @calendarable.events.searchlogic
      end
    end
    
    if params[:calendar_ids] && !params[:calendar_ids_all]
      scope = scope.calendar_id_is_any(params[:calendar_ids])
    end
    
    if params[:project_ids]# && !params[:project_ids_all]
      scope = scope.calendar_calendarable_type_is("Project")
      scope = scope.calendar_calendarable_id_is_any(params[:project_ids])
    end
    
    respond_to do |format|
      format.html {
        @event_strips = scope.event_strips_for_month(@shown_month)
      }
      format.js {
        @event_strips = scope.event_strips_for_month(@shown_month)
      }
      format.ical {
        @ical = RiCal.Calendar do |cal|
          @calendarable.calendar.events.each do |event|
            cal.event do
              uid       event.uid
              sequence  event.sequence
              summary   event.summary
              location  event.location
              dtstart   event.start_at
              dtend     event.end_at
            end
          end
        end
        render :text => @ical
      }
    end
  end
  
  def show
  end
  
  def new
  end
  
  def create
    if params[:event][:repeat_frequency].present?
      @event = @calendarable.calendar.event_series.new(params[:event])
    else
      @event = @calendarable.calendar.events.new(params[:event])
    end
    if @event.save
      flash[:notice] = "Event was created."
      redirect_to [@calendarable, :events]
    else
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    if params[:event][:repeat_frequency].present? && (!@event.recurring? || params[:commit] == "Update all events in the series")
      @event = @event.update_series(params[:event])
    else
      @event.update_attributes(params[:event])
    end
    
    if @event.errors.empty?
      flash[:notice] = "Event updated."
    end
    respond_to do |format|
      format.html {
        if @event.errors.empty?
          redirect_to [@calendarable, @event.is_a?(Event) ? @event : :events]
        else
          render :action => :edit
        end
      }
      format.js {
        render :update do |page|
          page << show_flash_messages
        end
      }
    end
  end
  
  def destroy
    if params[:remove_series]
      @event.event_series.destroy
    else
      @event.destroy
    end
    flash[:notice] = "Event deleted."
    respond_to do |format|
      format.html { redirect_to @calendarable }
      format.js {
        render :update do |page|
          page << show_flash_messages
        end
      }
    end
  end
  
  private
  
  def find_event
    @event = Event.find(params[:id])
  end
end