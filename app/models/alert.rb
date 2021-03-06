class Alert < ActiveRecord::Base
  
  default_scope :order => "id desc"
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
    alert.created_at = DateTime.now
    alert.updated_at = DateTime.now
    alert.alert_type = alerttype
    alert.deleted_text = deletedtext
    alert.save
    #~ if fromtype == "Task"
      #~ Comment.create( :commentable_id =>fromid, :commentable_type = fromtype, :is_spam = 0, :source = "Alert", :message = "test", :created_by = createdby, :created_at = Date.today)
    #~ end
  end
  
  def alertable_s
    if deleted_text != nil
      return deleted_text.to_s
    end
    return alertable.to_s
  end
  
  def is_deleted?
    if deleted_text != nil
      return true
    end
    return false
  end
  
  def color_alertabletype
    case alertable_type
      when 'Asset'
      return "<span class=\"filetag\">File</span>"
      when 'Task'
      return "<span class=\"tasktag\">Task</span>"
      when 'Article'
      return "<span class=\"feedtag\">Snippet</span>"
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
