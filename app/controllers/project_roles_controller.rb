class ProjectRolesController < ApplicationController
  
  before_filter :login_required
  before_filter :find_project
  
  def index
    @roles = @project.roles
  end
  
end