class NotificationsController < ApplicationController
  
  before_filter :find_project
  
  def update
    @notification = @project.getnotify(current_user.id)
    if @notification.update_attributes(params[:notification])
      flash[:notice] = "Notification updated."
    end
    respond_to do |format|
      format.html { redirect_to [@project, :alerts] }
    end
  end
  
end