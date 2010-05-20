class CommentObserver < ActiveRecord::Observer
  
  def after_create(comment)
    Alert.log(comment.commentable.project_id, comment.commentable_id, comment.commentable_type, nil, "commented", comment.created_by, nil)
  end
end