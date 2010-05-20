class ArticleObserver < ActiveRecord::Observer
  
  def after_create(article)
    Alert.log(article.project_id, article.id, "Article", nil, "added", article.created_by, nil)
  end
  
  def after_destroy(article)
    Alert.log(article.project_id, article.id, "Article", nil, "deleted", article.created_by, article.title)
  end
    
end