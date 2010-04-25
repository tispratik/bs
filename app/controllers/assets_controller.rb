class AssetsController < ApplicationController
  
  before_filter :login_required
  before_filter :find_asset, :except => [:index, :new, :create]
  before_filter :find_project, :only => [:index]
  before_filter :check_project_membership
  
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
    @asset = Asset.find(params[:id])
    @project = @asset.attachable.project
  end
  
  def get_query
    qry = "@project.assets.status_eq(#{Decode::BS_ASSET_STATUS_AC})"
    qry = qry + sort_order('descend_by_created_at') 
    #qry = qry + ".all(:include => {:modul => [:creator, :updator, :parent]})"
    qry = qry + ".paginate(:page => #{params[:page] || 1}, :per_page => 15)"
  end
end
