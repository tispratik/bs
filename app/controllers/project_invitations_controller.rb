class ProjectInvitationsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_project
  
  def new
  end
  
  def create
    @invitation = @project.invitations.new(params[:project_invitation])
    
    if @invitation.save
      flash[:notice] = "Invitation created."
    else
      flash[:notice] = "User not found or already invited."
    end
    redirect_to @project
  end
  
  def confirm
    @invitation = @project.invitations.find(params[:id])
    
    if @invitation.user == current_user && @invitation.confirm
      flash[:notice] = "Invitation confirmed."
    else
      flash[:notice] = "Error happened."
    end
    redirect_to @invitation.user
  end

end