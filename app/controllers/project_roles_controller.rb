class ProjectRolesController < ApplicationController
  
  before_filter :find_project
  
  def index
    @roles = @project.roles
  end
  
end