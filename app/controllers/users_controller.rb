class UsersController < ApplicationController
  
  before_filter :find_project, :except => [:me, :show]
  
  def show
    redirect_to :action => :me
  end
  
  def me
    @user = current_user
    sub_qry
    render :show
  end
  
  #  def index
  #    @users = eval(get_query)
  #  end
  #    
  #  private
  #  
  #  def get_query
  #    qry = "@project.users"
  #    qry = qry + sort_order('ascend_by_username') 
  #    qry = qry + ".paginate(:page => #{params[:page] || 1}, :per_page => 8)"
  #  end
  
  def sub_qry
    sub_qry = sort_order('descend_by_created_at')
    sub_qry = sub_qry + ".all(:include => [:assignee, :initiator, :updator, :project, :priorityDecode])"
    @my_tasks = eval('Task.my' + sub_qry + ".paginate(:page => #{params[:upper] || 1}, :per_page => 10)")
    @my_related = eval('Task.my_related' + sub_qry + ".paginate(:page => #{params[:lower] || 1}, :per_page => 10)") 
  end
end