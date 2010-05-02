class AssetsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_project
  before_filter :find_asset, :except => [:index, :new, :create]
  before_filter :check_project_membership
  before_filter :check_ownership, :only => [:destroy]
  
  def index
    @asset = Asset.new
    @assets = eval(get_query)
  end
  
  def destroy
    @asset = Asset.find(params[:id])
    @asset.destroy
    flash[:notice] = "Attachment removed."
    redirect_to [@asset.attachable.project, :articles]
  end
  
  def show
    send_file @asset.data.path(params[:style]), :type => @asset.data_content_type, :disposition => 'inline'
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
