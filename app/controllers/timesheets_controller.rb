class TimesheetsController < ApplicationController
  
  before_filter :find_project
  before_filter :login_required
  
  def index
    @timesheets = @project.timesheets.searchlogic
    @archieved = @project.is_archieved?
    @learnmore = "Timesheets lets you keep a record of how long have you worked on what for this project."
    
    @timesheet_user = (params[:user_id]) ? @project.users.find(params[:user_id]) : current_user
    @timesheets = @timesheets.user_id_is(@timesheet_user.id)
    
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
          page << "$('#timesheets').html(\"#{escape_javascript(render :partial => 'timesheets')}\");"
          page << ((@timesheet_user == current_user) ? "$('#new_timelog').show();" : "$('#new_timelog').hide();")
        end
      }
    end
  end
  
  def export_csv
    csv_string = FasterCSV.generate do |csv|
      csv << ["Name", "Description", "Date", "Hours Reported"]
      @project.timesheets.each do |t|
        t.timelogs.each do |tl|
          csv << [t.user.to_s(), t.description, tl.date, tl.hours]
        end
      end
    end
    send_data(csv_string, :type => 'text/csv', :filename => 'timesheets.csv', :disposition => 'inline')
  end
  
  def suggest
    @timesheets = @project.timesheets.searchlogic
    if params[:q]
      @timesheets.description_like(params[:q])
    end
    render :text => @timesheets.collect(&:description).join("\n")
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