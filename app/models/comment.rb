class Comment < ActiveRecord::Base

  default_scope :order => 'created_at asc'
  belongs_to :commentable, :polymorphic => true
  belongs_to :creator, :class_name => 'User', :foreign_key => "created_by"
  belongs_to :parent_comment, :foreign_key => :parent_id
  
  validates_presence_of :commentable, :creator, :message
  
  def before_validation_on_create
    self.source = "Web" unless source.present?
    self.created_by = User.curr_user.id
  end
  
  def formatted_message
    message.gsub(/\n/, "<br/>")
  end

end