class ArticleObserver < ActiveRecord::Observer
  
  def after_create(article)
    Alert.log(article.project_id, article.id, "Article", nil, "added", article.created_by, nil)
    Consumption.add(article.project_id , 'BS_CONSP_SN', 1)
  end
  
  def after_destroy(article)
    Alert.log(article.project_id, article.id, "Article", nil, "deleted", article.created_by, article.title)
    Consumption.sub(article.project_id , 'BS_CONSP_SN', 1)
  end
    
end