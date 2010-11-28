class ProjectsController < ApplicationController
  
  before_filter :find_project, :only => [:show, :edit, :update, :destroy]
  before_filter :check_project_membership, :only => [:show]
  before_filter :check_project_ownership, :only => [:edit, :update, :destroy]
  before_filter :find_projects_user, :only => :index
  
  def index
    opts = {}
    opts[:order] = params[:order_by] if params[:order_by]
    @project = current_user.projects.new
    @projects = current_user.projects.paginate(opts.merge(:page => params[:page] || 1, :per_page => 10))
  end
  
  def show
    @alerts = @project.alerts.all(:limit => 10)
    @cusage = 0#((Consumption.get(@project.id ,"BS_CONSP_DS").to_f() / 1024) / 1024)
    cpercent = 0#(@cusage/20)*100
    npercent = 0#100 - cpercent
    @comp = "<span id=\"complete\" style=\"width:" + cpercent.to_s() + "%\"></span>"
    @notcomp = "<span id=\"notcomplete\" style=\"width:" + npercent.to_s() + "%\"> </span>"
    @totalavail = 20
    @istimesheet = true
    if @project.timesheets == nil 
     @istimesheet = false
    elsif @project.timesheets.empty?
      @istimesheet = false
    end
  end
  
  def create
    @project = Project.new(params[:project])
    
    if @project.save
      #Consumption.on_create_project(@project.id)
      flash[:notice] = 'Project was successfully created.'
      redirect_to @project
    else
      render :new
    end
  end
  
  def edit
    if @project.project_logo == nil
      @islogonew = true
      @project_logo = @project.project_logo.new
    else
      @project_logo = @project.project_logo
      @islogonew = false
    end
  end
  
  def update
    if @project.update_attributes(params[:project])
      flash[:notice] = 'Project was successfully updated.'
      redirect_to @project
    else
      render :edit
    end
  end
  
  def destroy
    @project.destroy
    flash[:notice] = 'Project was successfully removed.'
    redirect_to projects_path
  end
  
  private
  
  def find_project
    params[:project_id] = params[:id]
    super
  end
  
  def find_projects_user
    if params[:user_id]
      @user = User.find_by_username(params[:user_id])
    end
  end
    
end
