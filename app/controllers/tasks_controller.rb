class TasksController < ApplicationController
  require 'FasterCSV'
  
  before_filter :login_required
  before_filter :find_project
  before_filter :find_task, :except => [:index, :new, :create, :export_csv]
  before_filter :check_project_membership
  before_filter :check_ownership, :only => [:edit, :update, :destroy]
  
  # GET /tasks
  # GET /tasks.xml
  def index
    @tasks = eval(get_query)
    @task = @project.tasks.build
    @archieved = @project.is_archieved?
    @learnmore = "Tasks help you keep track of all the little things that need to get done. You can add them for yourself or assign them to someone else."
    render :layout => 'onebox_layout'
  end
  
  def export_csv
    csv_string = FasterCSV.generate do |csv|
      csv << ["name", "assigned to", "due date", "priority", "status", "creator", "updator", "created_at", "updated_at"]
      @project.tasks.each do |t|
        csv << [t.name, t.assignee.to_s(), t.due_date, t.priorityDecode.display_value, t.statusDecode.display_value, t.initiator.to_s(), t.updator.to_s(), t.created_at, t.updated_at]
      end
    end
    send_data(csv_string, :type => 'text/csv', :filename => 'tasks.csv')
  end
  
  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @task = @project.tasks.build
  end
  
  # GET /tasks/1/edit
  def edit
    #Deliberately adding parent condition
    #If someone tries to access a task not belonging to any of his projects directly by manipulating the URL,
    #a ActiveRecord::RecordNotFound exception will be thrown since the task is project scoped
    @archieved = @project.is_archieved?
    @newtask = @project.tasks.build
    if @task.nil?
      record_not_found
    end
    render :layout => 'onebox_layout'
  end
  
  def show
    redirect_to edit_project_task_path(@project, @task)
  end
  
  # POST /tasks
  # POST /tasks.xml
  def create
    @task = @project.tasks.build(params[:task])
    #alias field is non mandatory
    
    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to [@project, :tasks] }
        format.xml  { render :xml => @task, :status => :created, :location => @task }
      else
        flash[:notice] = 'Failed to create task.'
        flash[:errors] = @task.errors.full_messages.join('<br />')
        format.html { redirect_to :back }
      end
    end
  end
  
  # PUT /tasks/1
  # PUT /tasks/1.xml
  def update
    respond_to do |format|
      if @task.update_attributes(params[:task])
        flash[:notice] = 'Successfully updated task.'
        format.html { redirect_to :back }
        format.xml {  }
      else
        format.html render :action => "edit"
      end
    end
  end
  
  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task.update_attribute(:deleted_at, Time.now)
    flash[:notice] = "Task closed successfully."
    redirect_to :back
  end
  
  def reopen
    @task.update_attribute(:deleted_at, nil)
    flash[:notice] = "Task re-opened successfully."
    redirect_to :back
  end
  
  private 
  
  def find_task
    @task = @project.tasks.find(params[:id])
  end
  
  def check_ownership
    if current_user == @task.initiator || current_user == @task.assignee
      #allowed to proceed
    else
      flash[:notice] = "Not permitted."
      redirect_to :action => :index
    end
  end
  
  def get_query
    qry = "@project.tasks"
    
    if !params[:created_by].nil?
      qry = qry + ".created_by_eq(#{params[:created_by]})"
    end
    if !params[:assign_to].nil?
      qry = qry + ".assign_to_eq(#{params[:assign_to]})"
    end
    if !params[:status].nil?
      qry = qry + ".status_eq(#{params[:status]})"
    end
    if params[:due_date] == "today"
      qry = qry + ".due_date_eq('#{Date.today}')"
    end
    if params[:due_date] == "tomorrow"
      qry = qry + ".due_date_eq('#{Date.tomorrow}')"
    end
    if params[:due_date] == "eow"
      qry = qry + ".due_date_gte('#{Date.today}').due_date_lte('#{Date.today.end_of_week}')"
    end
    if params[:due_date] == "past"
      qry = qry + ".due_date_lt('#{Date.today}')"
    end
    if !params[:task_type].nil?
      qry = qry + ".task_type_eq('#{params[:task_type]}')"
    end
    if !params[:priority].nil?
      qry = qry + ".priority_eq('#{params[:priority]}')"
    end
    if !params[:search].blank?
      qry = qry + ".name_like_any(params[:search].split)"
    end
    
    qry = qry + sort_order('ascend_by_due_date')
    qry = qry + ".all(:include => [:assignee, :initiator, :updator, :project, :priorityDecode])"
    qry = qry + ".paginate(:page => #{params[:page] || 1}, :per_page => 30)"
  end
  
end
