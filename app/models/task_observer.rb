class TaskObserver < ActiveRecord::Observer
  
  def after_create(task)
    Alert.log(task.project_id, task.id, "Task", task.due_date, "added", task.created_by, nil)
  end
  
  def after_update(task)
    if task.deleted_at == nil
      Alert.log(task.project_id, task.id, "Task", task.due_date, "updated", task.created_by, nil)
    else
      Alert.log(task.project_id, task.id, "Task", task.due_date, "completed", task.created_by, nil)
    end
  end
  
end