class TasksController < ApplicationController
  
  before_filter :login_required
  before_filter :find_project
  before_filter :find_task, :except => [:index, :new, :create]
  before_filter :check_project_membership
  before_filter :check_ownership, :only => [:edit, :update, :destroy]
  
  # GET /tasks
  # GET /tasks.xml
  def index
    @tasks = eval(get_query)
  end
  
  # GET /tasks/new
  # GET /tasks/new.xml
  def new
    @project = Project.find(params[:project_id])
    @task = Task.new
    @task.project = @project
    @page = Page.pageobj('pg_add_task')
  end
  
  # GET /tasks/1/edit
  def edit
    #Deliberately adding parent condition
    #If someone tries to access a task not belonging to any of his projects directly by manipulating the URL,
    #a ActiveRecord::RecordNotFound exception will be thrown since the task is project scoped
    if @task.nil?
      record_not_found
    end
    @page = Page.pageobj('pg_edit_task')
  end
  
  def show
    record_not_found
  end
  
  # POST /tasks
  # POST /tasks.xml
  def create
    @task = @project.tasks.build(params[:task])
    #alias field is non mandatory
    
    respond_to do |format|
      if @task.save
        flash[:notice] = 'Task was successfully created.'
        format.html { redirect_to edit_project_task_path(@project, @task) }
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
        @task.updated_by = current_user.id
        @task.save
        flash[:notice] = 'Successfully updated task.'
        format.html { redirect_to :back }
      else
        format.html render :action => "edit"
      end
    end
  end
  
  # DELETE /tasks/1
  # DELETE /tasks/1.xml
  def destroy
    @task = Task.find(params[:id])
    @task.destroy
    
    respond_to do |format|
      format.html { redirect_to(tasks_url) }
      format.xml  { head :ok }
    end
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
    
    qry = qry + sort_order('descend_by_created_at')
    qry = qry + ".all(:include => [:assignee, :initiator, :updator, :project, :statusDecode, :priorityDecode])"
    qry = qry + ".paginate(:page => #{params[:page] || 1}, :per_page => 20)"
  end
end
