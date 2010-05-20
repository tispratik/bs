class Alert < ActiveRecord::Base
  
  belongs_to :project
  belongs_to :creator, :class_name => 'User', :foreign_key => "created_by"
  belongs_to :alertable, :polymorphic => true
  
  def self.log(projid, fromid, fromtype, duedate, alerttype, createdby, deletedtext)
    alert = Alert.new
    alert.project_id = projid
    alert.created_by = createdby
    alert.alertable_id = fromid
    alert.alertable_type = fromtype
    alert.due_date = duedate
    alert.created_at = Date.today
    alert.updated_at = Date.today
    alert.alert_type = alerttype
    alert.deleted_text = deletedtext
    alert.save
  end
    
  def self.forproject(projectid, count)
    #a = Alert.all(:select => "alertable_id, alertable_type, id", :conditions => {:project_id => projectid }, :group => "alertable_id, alertable_type",:having => "max(id)", :limit => count)
    a = Alert.all(:conditions => {:project_id => projectid }, :order => "id desc", :limit => count)
    if a == nil or a.empty?
      return Array.new
    else
      return a
    end  
  end
  
  def alertable_s
    if deleted_text != nil
      return deleted_text.to_s()
    end
    return alertable.to_s()
  end  
  
  def is_deleted?
    if deleted_text != nil
      return true
    else
      return false
    end  
  end
  
  def color_alertabletype
    case alertable_type
      when 'Asset'
        return "<span class=\"filetag\">File</span>"
      when 'Task'
        return "<span class=\"tasktag\">Task</span>"
      when 'Article'
        return "<span class=\"feedtag\">Feed</span>"
      when 'WikiPage'
        return "<span class=\"coedittag\">CoEdit</span>"
    end
  end
    
  def alertable_link
    case alertable_type
      when 'Asset'
        return "<span class=\"filetag\">File</span>"
      when 'Task'
        return "<span class=\"tasktag\">Task</span>"
      #when 'Article'
        #return link_to alertable.to_s(), project_article_path (alertable_id)
      when 'WikiPage'
        return "<span class=\"coedittag\">CoEdit</span>"
    end
  end  
    
end
