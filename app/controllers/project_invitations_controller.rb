class ProjectInvitationsController < ApplicationController
  
  before_filter :find_project
  before_filter :find_invitation, :except => [:new, :create]
  
  def new
  end
  
  def create
    @invitation = @project.invitations.new(params[:project_invitation])
    if @invitation.save
      flash[:notice] = "Invitation created."
      # send invitation email to user
      UserMailer.deliver_project_invitation(@invitation.user_email, current_user)
    else
      flash[:notice] = "User not found or already invited."
    end
    redirect_to [@project, :project_roles]
  end
  
  def confirm
    if @invitation.user == current_user && @invitation.confirm
      flash[:notice] = "Invitation confirmed."
    else
      flash[:notice] = "Error happened."
    end
    redirect_to @invitation.user
  end
  
  def resend
    UserMailer.deliver_project_invitation(@invitation.user_email, current_user)
    flash[:notice] = "Invitation email sent."
    redirect_to [@project, :project_roles]
  end
  
  def destroy
    @invitation.destroy
    flash[:notice] = "Invitation removed."
    redirect_to [@project, :project_roles]
  end
  
private

  def find_invitation
    @invitation = @project.invitations.find_by_token(params[:id])
  end

end