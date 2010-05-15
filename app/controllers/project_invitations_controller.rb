class ProjectInvitationsController < ApplicationController
  
  before_filter :find_project
  
  def new
  end
  
  def create
    @invitation = @project.invitations.new(params[:project_invitation])
    
    if @invitation.save
      flash[:notice] = "Invitation created."
      unless @invitation.user.present?
        # send invitation email to user
        UserMailer.deliver_project_invitation(@invitation.user_email, current_user)
      end
    else
      flash[:notice] = "User not found or already invited."
    end
    redirect_to [@project, :project_roles]
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