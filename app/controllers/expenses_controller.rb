class ExpensesController < ApplicationController
  
  before_filter :find_project
  
  def index
    @expenses = @project.expenses.searchlogic
    @archieved = @project.is_archieved?
    @learnmore = "..."
    
    @expense_user = (params[:user_id]) ? @project.users.find(params[:user_id]) : current_user
    @expenses = @expenses.user_id_is(@expense_user.id)
    
    if params[:date_from] && params[:date_from].present?
      @expenses = @expenses.timelogs_date_greater_than(params[:date_from])
    end
    if params[:date_to] && params[:date_to].present?
      @expenses = @expenses.timelogs_date_less_than(params[:date_to])
    end
    
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page << "$('#expenses').html(\"#{escape_javascript(render :partial => 'expenses')}\");"
          page << ((@expense_user == current_user) ? "$('#new_expenselog').show();" : "$('#new_expenselog').hide();")
        end
      }
    end
  end
  
  def suggest
    @expenses = @project.expenses.searchlogic
    if params[:q]
      @expenses.description_like(params[:q])
    end
    render :text => @expenses.collect(&:description).join("\n")
  end
  
  def update
    @expense = @project.expenses.find(params[:id])
    if @expense.update_attributes(params[:expense])
      flash[:notice] = "Expense updated."
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
  
  def destroy
    @expense = @project.expenses.find(params[:id])
    if @expense.user_id == current_user.id
      @expense.destroy
      flash[:notice] = "Expense removed."
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