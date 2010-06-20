class ExpenselogsController < ApplicationController
  
  before_filter :find_project
  
  def new
    @expenselog = Expenselog.new
  end
  
  def create
    @expenselog = @project.expenselogs.new(params[:expenselog])
    if @expenselog.save
      flash[:notice] = "Expenselog created."
    end
    respond_to do |format|
      format.html {
        if @expenselog.errors.empty?
          redirect_to [@project, :expenses]
        else
          render :action => :new
        end
      }
      format.js
    end
  end
  
  def destroy
    @expenselog = @project.expenselogs.find(params[:id])
    if @expenselog.expense.user_id == current_user.id
      @expenselog.destroy
      flash[:notice] = "Expenselog removed."
    else
      flash[:error] = "You don't have permissions."
    end
    respond_to do |format|
      format.html { redirect_to [@project, :expenses] }
      format.js {
        render :update do |page|
          page << show_flash_messages
        end
      }
    end
  end
  
end