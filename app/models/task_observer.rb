class TaskObserver < ActiveRecord::Observer
  
  def after_create(task)
    Alert.log(task.project_id, task.id, "Task", task.due_date, "added", task.created_by, nil)
    Consumption.add(task.project_id , 'BS_CONSP_OT', 1)
  end
  
  def after_update(task)
    if task.deleted_at == nil
      Alert.log(task.project_id, task.id, "Task", task.due_date, "updated", task.created_by, nil)
      Consumption.add(task.project_id , 'BS_CONSP_UT', 1)
    else
      Alert.log(task.project_id, task.id, "Task", task.due_date, "completed", task.created_by, nil)
      Consumption.add(task.project_id , 'BS_CONSP_CT', 1)
    end
  end
  
end