class TimelogsController < ApplicationController
  
  before_filter :find_project
  
  def new
    @timelog = Timelog.new
  end
  
  def create
    @timelog = @project.timelogs.new(params[:timelog])
    if @timelog.save
      flash[:notice] = "Timelog created."
      redirect_to [@project, :timesheets]
    else
      render :action => :new
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
    redirect_to [@project, :timesheets]
  end
  
end