class WikiPagesController < ApplicationController

  before_filter :login_required
  before_filter :find_project
  before_filter :find_wiki_page, :except => [:index, :new, :create]
  before_filter :check_project_membership
  before_filter :check_ownership, :only => [:destroy]
  
  def index
    @archieved = @project.is_archieved?
    @wiki_pages = @project.wiki_pages
    @learnmore = "CoEdits make collaborative writing easy. CoEdits help you track changes, make corrections and compare versions for changes. Use CoEdits to write solo or collaborate with others."
  end
  
  def show
    @archieved = @project.is_archieved?
    @wiki_page.revert_to(params[:version].to_i) if params[:version]
  end
  
  def diff
    @archieved = @project.is_archieved?
    if params[:versions]
      @changes_from, @changes_to = params[:versions].map(&:to_i)
    else
      @changes_from, @changes_to = (@wiki_page.version) - 1, @wiki_page.version
    end
    
    @wiki_page.revert_to(@changes_from)
    @content_from = @wiki_page.content.to_s
    @wiki_page.revert_to(@changes_to)
    @content_to = @wiki_page.content.to_s
  end
  
  def new
    @wiki_page = @project.wiki_pages.build
  end
  
  def create
    @wiki_page = WikiPage.new(params[:wiki_page])
    @wiki_page.project = @project
    if @wiki_page.save
      flash[:notice] = "CoEdit page was created."
      redirect_to edit_polymorphic_path([@project, @wiki_page])
    else
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @wiki_page.update_attributes(params[:wiki_page].merge(:updated_by => current_user))
      flash[:notice] = "CoEdit page was updated."
      redirect_to :action => :index
    else
      render :edit
    end
  end
  
  def destroy
    @wiki_page.update_attribute(:deleted_at, Time.now)
    flash[:notice] = "CoEdit page was removed."
    redirect_to :action => :index
  end
  
  def restore
    @wiki_page.update_attribute(:deleted_at, nil)
    flash[:notice] = "CoEdit page was restored."
    redirect_to :action => :index
  end
  
  private
  
  def find_wiki_page
    @wiki_page = @project.wiki_pages.find(params[:id])
  end
  
  def check_ownership
    if current_user.id == @wiki_page.created_by
      #allowed to proceed
    else
      flash[:notice] = "Not permitted."
      redirect_to :action => :index
    end
  end
end