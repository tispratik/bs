class EventsController < ApplicationController
  
  layout proc{ |c| c.request.xhr? ? false : "application" }
  
  before_filter :find_calendarable, :only => :index
  before_filter :find_event, :except => [:index, :new, :create]
  
  def index
    @month = (params[:month] || Time.zone.now.month).to_i
    @year = (params[:year] || Time.zone.now.year).to_i
    @shown_month = Date.civil(@year, @month)
    
    scope = Event.calendar_calendarable_id_is(@calendarable.id).calendar_calendarable_type_is(@calendarable.class.to_s)
    if params[:calendar_ids]
      scope = scope.calendar_id_is_any(params[:calendar_ids])
    end

    @event_strips = scope.event_strips_for_month(@shown_month)
  end
  
  def show
  end
  
  def new
  end
  
  def create
    @event = Event.new(params[:event])
    if @event.save
      flash[:notice] = "Event was created."
      redirect_to [@event.calendar.calendarable, :events]
    else
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    if @event.update_attributes(params[:event])
      flash[:notice] = "Event updated."
    else
      render :action => :edit
    end
    respond_to do |format|
      format.html { redirect_to [@event.calendar.calendarable, :events] }
      format.js {
        render :update do |page|
          page << show_flash_messages
        end
      }
    end
  end
  
  def destroy
    @event.destroy
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
  
  def find_calendarable
    if params[:project_id]
      @calendarable = @project = Project.find_by_permalink(UrlStore.decode(params[:project_id]))
    elsif params[:user_id]
      @calendarable = @user = User.find_by_username(params[:user_id])
    else
      @calendarable = @user = current_user
    end
  end
  
  def find_event
    @event = Event.find(params[:id])
  end
end