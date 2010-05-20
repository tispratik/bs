class TimesheetsController < ApplicationController
  
  before_filter :find_project
  
  def index
    @timesheets = @project.timesheets.searchlogic
    
    if params[:user_ids]
      @timesheets = @timesheets.user_id_is(params[:user_ids])
    end
    
    if params[:date_from] && params[:date_from].present?
      @timesheets = @timesheets.timelogs_date_greater_than(params[:date_from])
    end
    if params[:date_to] && params[:date_to].present?
      @timesheets = @timesheets.timelogs_date_less_than(params[:date_to])
    end
    
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page << "$('#timesheets').html(\"#{escape_javascript(render @timesheets.all)}\")"
        end
      }
    end
  end
  
  def update
    @timesheet = @project.timesheets.find(params[:id])
    if @timesheet.update_attributes(params[:timesheet])
      flash[:notice] = "Timesheet updated."
    end
    respond_to do |format|
      format.html { redirect_to [@project, :timesheets] }
      format.js {
        render :update do |page|
          page << show_flash_messages
        end
      }
    end
  end
  
  def destroy
    @timesheet = @project.timesheets.find(params[:id])
    if @timesheet.user_id == current_user.id
      @timesheet.destroy
      flash[:notice] = "Timesheet removed."
    else
      flash[:error] = "You don't have permissions."
    end
    redirect_to [@project, :timesheets]
  end
  
end