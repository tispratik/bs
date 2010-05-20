class TimelogsController < ApplicationController
  
  before_filter :find_project
  
  def new
    @timelog = Timelog.new
  end
  
  def create
    @timelog = @project.timelogs.new(params[:timelog])
    if @timelog.save
      flash[:notice] = "Timelog created."
    end
    respond_to do |format|
      format.html {
        if @timelog.errors.empty?
          redirect_to [@project, :timesheets]
        else
          render :action => :new
        end
      }
      format.js
    end
  end
  
  def destroy
    @timelog = @project.timelogs.find(params[:id])
    if @timelog.timesheet.user_id == current_user.id
      @timelog.destroy
      flash[:notice] = "Timelog removed."
    else
      flash[:error] = "You don't have permissions."
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
  
end