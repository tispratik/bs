class AssetObserver < ActiveRecord::Observer
  
  def after_create(asset)
    case asset.attachable_type 
      when 'Project'
        Alert.log(asset.attachable_id, asset.id, 'Asset', nil, "added", asset.created_by, nil)
    end
  end
  
  def after_destroy(asset)
    case asset.attachable_type 
      when 'Project'
        Alert.log(asset.attachable_id, asset.id, 'Asset', nil, "deleted", asset.created_by, asset.data_file_name)
    end
  end
  
end