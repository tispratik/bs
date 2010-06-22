class AlertsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_project
  before_filter :check_project_membership
  before_filter :check_ownership, :only => [:edit, :update, :destroy]
  
  def index
    @alerts = get_query(@project.id)
    @notification = @project.getnotify(current_user.id)
    @learnmore = "Alerts are short, to the point lines which capture all changes in the project. They are a great way to keep up-to-date."
  end
  
  def get_query(projectid)
    qry = "SELECT alertable_type, alertable_id, max(id) as id FROM bs_development.alerts a WHERE project_id = " + projectid.to_s() + " "   
    if !params[:alertable_type].nil?
      qry = qry + " AND alertable_type = \"" + params[:alertable_type] + "\" "
    end
    if !params[:alert_type].nil?
      qry = qry + " AND alert_type = \"" + params[:alert_type] + "\" "
    end
    qry = qry + " GROUP BY alertable_type, alertable_id ORDER BY id DESC;"
    
    a_max = Alert.find_by_sql(qry)
    returnlist = []
    a_max.each do |a|
      returnlist << Alert.find_by_id(a.id)
    end
    if returnlist == nil or returnlist.empty?
      return Array.new
    end
    return returnlist
  end
end