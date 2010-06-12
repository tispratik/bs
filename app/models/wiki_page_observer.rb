class WikiPageObserver < ActiveRecord::Observer
  
  def after_create(wikipage)
    Alert.log(wikipage.project_id, wikipage.id, "WikiPage", nil, "added", wikipage.created_by, nil)
    Consumption.add(wikipage.project_id , 'BS_CONSP_CO', 1)
  end
   
  def after_update(wikipage)
    if wikipage.deleted_at == nil
      Alert.log(wikipage.project_id, wikipage.id, "WikiPage", nil, "updated", wikipage.created_by, nil)
    else
      Alert.log(wikipage.project_id, wikipage.id, "WikiPage", nil, "deleted", wikipage.created_by, nil)
      Consumption.sub(wikipage.project_id , 'BS_CONSP_CO', 1)
    end
  end
  
end