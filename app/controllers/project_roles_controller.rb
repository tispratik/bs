class ProjectRolesController < ApplicationController
  
  before_filter :find_project
  
  def index
    @roles = @project.roles
    @count = @project.roles.size
  end
  
end