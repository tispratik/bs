class ProjectsController < ApplicationController
  
  before_filter :find_project, :only => [:show, :edit, :update, :destroy]
  before_filter :check_project_membership, :only => [:show]
  before_filter :check_project_ownership, :only => [:edit, :update, :destroy]
  
  def index
    opts = {}
    opts[:order] = params[:order_by] if params[:order_by]
    
    @projects = current_user.projects.paginate(opts.merge(:page => params[:page] || 1, :per_page => 10))
  end
  
  def show
    @count = 10
  end
  
  def new
    @project = current_user.projects.new
  end
  
  def create
    @project = Project.new(params[:project])
    
    if @project.save
      flash[:notice] = 'Project was successfully created.'
      redirect_to @project
    else
      render :new
    end
  end
  
  def edit
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
    
end
