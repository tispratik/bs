class ProjectLogosController < ApplicationController

  downloads_files_for :project_logo, :image
  before_filter :login_required
  before_filter :find_project
  before_filter :check_project_membership
  #before_filter :check_ownership, :only => [:edit, :update, :destroy, :new, :create]

  def edit
    @project_logo = @project.project_logo
  end

  def show
    send_file @project.project_logo.image_file.url
  end
  
  def create
    @project_logo = @project.build_project_logo(params[:project_logo])
     if @project_logo.save
       redirect_to edit_project_path(@project)
     end
  end

  def update
    @project_logo = @project.project_logo

    if @project_logo.update_attributes(params[:project_logo])
      if params[:project_logo][:image].blank?
        redirect_to edit_project_path(@project)
      else
        redirect_to edit_project_path(@project)
      end
    else
      redirect_to edit_project_path(@project)
    end
  end

  def destroy
    @project.project_logo.destroy
    redirect_to(project_project_logo_path(@project_logo))
  end
  
end
