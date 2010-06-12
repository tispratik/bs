class ArticlesController < ApplicationController
  
  before_filter :find_project
  before_filter :find_article, :except => [:index, :new, :create, :search, :suggest]
  before_filter :check_project_membership
  before_filter :check_ownership, :only => [:edit, :update, :destroy]
  
  def index
    @archieved = @project.is_archieved?
    @articles = @project.articles.paginate(:per_page => 20, :page => params[:page], :order => "created_at desc")
    @learnmore = "Snippets are a dumping ground for unorganized text, images, links, videos, audio and files which you come across and feel that might be helpful to the project. Share snippets without cluttering inbox with FYI emails."
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def search
    conditions = {:project_id => @project.id}

    if params[:search].is_a?(Hash)
      date_within = params[:search].delete :citation_date_within
      if params[:search][:citation_date].present?
        date = params[:search].delete :citation_date
        begin
          if date == "today"
            date = Date.today
          else
            date = Date.parse date
          end
          date_within = eval(date_within)
          date_from = date - date_within
          date_to = date + date_within
          conditions[:citation_date] = date_from.to_time.to_i..date_to.to_time.to_i
        rescue
        end
      end
      query = params[:search].collect{ |k,v|
        unless v.empty?
          "@#{k} #{v}"
        end
      }.join(" ")
    else
      query = params[:search]
    end
    
    @articles = Article.search(query, :include => :creator,
      :with => conditions,
      :order => "created_at desc",
      :per_page => 100,
      :match_mode => :extended, :star => true, :retry_stale => true
    )
    
    render :action => :index
  end
  
  def suggest
    results = case params[:field]
    when "title" then
      @project.articles.all(:conditions => ["title like ?", "%#{params[:q]}%"]).collect(&:title)
    when "author" then
      User.all(
        :select => "usrs.*, (select count(id) from #{Article.connection.current_database}.#{Article.table_name} where created_by=usrs.user_id and project_id=#{@project.id}) as articles_count",
        :conditions => ["concat_ws(' ', first_name, last_name) like ?", "%#{params[:q]}%"],
        :group => "usrs.user_id", :having => "articles_count > 0"
      ).collect(&:to_s)
    when "tags" then
      @project.tags.all(:conditions => ["name like ?", "%#{params[:q]}%"]).collect(&:to_s)
    when "citation_source" then
      @project.articles.all(:conditions => ["citation_source like ?", "%#{params[:q]}%"], :group => :citation_source).collect(&:citation_source)
    when "citation_author" then
      @project.articles.all(:conditions => ["citation_author like ?", "%#{params[:q]}%"], :group => :citation_author).collect(&:citation_author)
    end
    render :text => results.join("\n")
  end
  
  def show
    @archieved = @project.is_archieved?
  end
  
  def new
    @article = @project.articles.build
  end
  
  def create
    @article = @project.articles.new(params[:article])
    if @article.save
      flash[:notice] = "Article was created."
      redirect_to :action => :index
    else
      flash[:notice] = "Failed to create article."
      render :action => :new
    end
  end
  
  def edit
  end
  
  def update
    if @article.update_attributes(params[:article])
      flash[:notice] = "Article was updated."
    end
    respond_to do |format|
      format.html { 
        if @article.errors.empty?
          redirect_to :action => :index
        else
          render :action => :edit
        end
      }
      format.js
    end
  end
  
  def destroy
    @article.destroy
    flash[:notice] = "Snippet was removed."
    redirect_to :action => :index
  end
  
  private
  
  def find_article
    @article = @project.articles.find(params[:id])
  end
  
  def check_ownership
    if current_user == @article.creator
      #allowed to proceed
    else
      flash[:notice] = "Not permitted."
      redirect_to :action => :index
    end
  end
  
end