class CommentsController < ApplicationController
  # before_filter :find_commentable, :except => :quote
  
  def new
    @comment = @commentable.comments.new
  end
  
  def create
    @comment = Comment.new(params[:comment])
    if @comment.save
      flash[:notice] = "Comment posted successfully."
    end
    respond_to do |format|
      format.html { 
        if @comment.errors.empty?
          redirect_to [@comment.commentable.project, @comment.commentable]
        else
          render :action => :new
        end
      }
      format.js
    end
  end
  
  def quote
    @comment = Comment.find(params[:id])
  end
  
  private
  
  def find_commentable
    if params[:article_id]
      @commentable = Article.find(params[:article_id])
    end
  end
  
end