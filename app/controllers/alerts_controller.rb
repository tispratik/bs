class AlertsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_project
  before_filter :check_project_membership
  before_filter :check_ownership, :only => [:edit, :update, :destroy]
  
  def index
    @alerts = eval(get_query)
    @notification = @project.getnotify(current_user.id)
    @learnmore = "Alerts are short, to the point lines which capture all changes in the project. They are a great way to keep up-to-date."
  end
  
  def get_query
    qry = "@project.alerts"
    
    if !params[:alertable_type].nil?
      qry = qry + ".alertable_type_eq(params[:alertable_type])"
    end
    if !params[:alert_type].nil?
      qry = qry + ".alert_type_eq(params[:alert_type])"
    end
#    if !params[:search].blank?
#      qry = qry + ".alertable_task_type_name_like_any(params[:search].split)"
#      qry = qry + ".alertable_article_type_title_like_any(params[:search].split)"
#      qry = qry + ".alertable_wiki_pages_type_title_like_any(params[:search].split)"
#    end

    qry = qry + sort_order('descend_by_created_at')
    qry = qry + ".all(:include => [:creator, :alertable])"
    qry = qry + ".paginate(:page => #{params[:page] || 1}, :per_page => 50)"
  end
end