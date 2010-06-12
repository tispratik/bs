class AssetsController < ApplicationController
  
  before_filter :find_project
  before_filter :find_asset, :except => [:index, :new, :create]
  before_filter :check_project_membership
  before_filter :check_project_ownership, :only => [:destroy]
  
  def index
    @asset = Asset.new
    @archieved = @project.is_archieved?
    @assets = eval(get_query)
    @learnmore = "Upload, download, and share files online with your team, clients, or colleagues."
    @cusage = ((Consumption.get(@project.id ,"BS_CONSP_DS").to_f() / 1024) / 1024)
    cpercent = (@cusage/20)*100
    npercent = 100 - cpercent
    @comp = "<span id=\"complete\" style=\"width:" + cpercent.to_s() + "%\"></span>"
    @notcomp = "<span id=\"notcomplete\" style=\"width:" + npercent.to_s() + "%\"> </span>"
    @totalavail = 20
  end
  
  def destroy
    @asset.destroy
    if @asset.attachable_type == "Project"
      Consumption.sub(@asset.attachable_id , 'BS_CONSP_DS', @asset.data_file_size)
    else
      Consumption.sub(@asset.attachable.project_id , 'BS_CONSP_DS', @asset.data_file_size)
    end    
    flash[:notice] = "File deleted."
    redirect_to :back
  end
  
  def show
    send_file @asset.data.path(params[:style]), :type => @asset.data_content_type, :disposition => 'inline'
  end
  
  def create
    @asset = @project.assets.build(params[:asset][:assets])
    #alias field is non mandatory
    
    if @asset.save
      if @asset.attachable_type == "Project"
        Consumption.add(@asset.attachable_id , 'BS_CONSP_DS', @asset.data_file_size)
      else
        Consumption.add(@asset.attachable.project_id , 'BS_CONSP_DS', @asset.data_file_size)
      end    
      flash[:notice] = 'File uploaded successfully.'
      redirect_to :back
    else
      flash[:notice] = 'Failed to upload file.'
      flash[:errors] = @asset.errors.full_messages.join('<br />')
      redirect_to :back
    end
  end
  
  private
  
  def find_asset
    @asset = @project.assets.find(params[:id])
  end
  
  def get_query
    qry = "@project.assets"
    qry = qry + sort_order('descend_by_created_at') 
    #qry = qry + ".all(:include => {:modul => [:creator, :updator, :parent]})"
    qry = qry + ".paginate(:page => #{params[:page] || 1}, :per_page => 15)"
  end
end
