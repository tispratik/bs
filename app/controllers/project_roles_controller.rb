class ProjectRolesController < ApplicationController
  
  before_filter :find_project
  before_filter :check_project_ownership, :only => [:update, :destroy]
  
  def index
    @roles = @project.roles
    @count = @project.roles.size
  end
  
  def update
    @role = @project.roles.find(params[:id])
    if @role.update_attributes(params[:project_role])
      flash[:notice] = "Role updated."
    end
    redirect_to :action => :index
  end
  
  def destroy
    @role = @project.roles.find(params[:id])
    @role.destroy
    flash[:notice] = "Role removed."
    redirect_to :action => :index
  end
  
end