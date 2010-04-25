class ProjectInvitationsController < ApplicationController

  def new
  end
  
  def create
    @project = Project.find_by_permalink(params[:project_id])
    @invitation = @project.invitations.new(params[:project_invitation])
    
    if @invitation.save
      flash[:notice] = "Invitation created."
    else
      flash[:notice] = "User not found or already invited."
    end
    redirect_to @project
  end
  
  def confirm
    @project = Project.find_by_permalink(params[:project_id])
    @invitation = @project.invitations.find(params[:id])
    
    if @invitation.user == current_user && @invitation.confirm
      flash[:notice] = "Invitation confirmed."
    else
      flash[:notice] = "Error happened."
    end
    redirect_to @invitation.user
  end

end