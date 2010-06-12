class AssetObserver < ActiveRecord::Observer
  
  def after_create(asset)
    if asset.attachable_type == 'Project'
      Alert.log(asset.attachable_id, asset.id, 'Asset', nil, "added", asset.created_by, nil)
      Consumption.add(asset.attachable_id , 'BS_CONSP_FL', 1)
    end
  end
  
  def after_destroy(asset)
    if asset.attachable_type == 'Project'
      Alert.log(asset.attachable_id, asset.id, 'Asset', nil, "deleted", asset.created_by, asset.data_file_name)
      Consumption.sub(asset.attachable_id , 'BS_CONSP_FL', 1)
    end
  end
  
end