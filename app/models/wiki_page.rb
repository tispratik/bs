class WikiPage < ActiveRecord::Base
  
  default_scope :order => "deleted_at asc, created_at desc"
  versioned :only => :content
  has_many :alerts, :as => :alertable
  
  has_many :comments, :as => :commentable
  belongs_to :project
  belongs_to :creator, :class_name => 'User', :foreign_key => "created_by"
  belongs_to :updator, :class_name => 'User', :foreign_key => "updated_by"
  scope :deleted, where('deleted_at != ?', nil)
  
  validates_associated :project
  validates_presence_of :project, :title
  before_create :run_before_create
  
  def to_s
    title
  end
  
  def versions_desc
    versions.reverse
  end
  
  def run_before_create
    self.created_by = User.curr_user.id
    self.updated_by = User.curr_user.id
  end
  
end
