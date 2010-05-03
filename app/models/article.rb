class Article < ActiveRecord::Base
  
  default_scope :order => "created_at desc"
  
  has_many :comments, :as => :commentable,  :dependent => :destroy
  has_many :tags,     :as => :taggable,     :dependent => :destroy
  has_many :assets,   :as => :attachable,   :dependent => :destroy
  belongs_to :project
  belongs_to :creator, :class_name => 'User', :foreign_key => "created_by"
  belongs_to :updator, :class_name => 'User', :foreign_key => "updated_by"
  
  validates_associated :project
  validates_presence_of :project, :title, :content
  
  accepts_nested_attributes_for :asset
  
  after_save :assign_tags
  before_save :set_article_delta_flag
  
  define_index do
    indexes title
    indexes content
    indexes citation_source
    indexes citation_author
    indexes tags.name, :as => :tags
    indexes "(select CONCAT_WS(' ', first_name, last_name) from #{Usr.connection.current_database}.#{Usr.table_name} u where u.user_id=articles.created_by)", :as => :author
    indexes assets.data_content_type, :as => :attachment_content_type
    # indexes [creator.first_name, creator.last_name], :as => :author
    
    has project_id, created_by, created_at, citation_date
    set_property :delta => :delayed
  end
  
  def to_s
    title
  end
  
  def before_create
    self.created_by = User.curr_user.id
    self.updated_by = User.curr_user.id
  end
  
  attr_writer :tag_list
  def tag_list
    @tag_list || tags.map(&:name).join(', ')
  end
  
  private
  
  def set_article_delta_flag
    self.delta = true
  end
  
  def assign_tags
    if @tag_list
      self.tags = @tag_list.split(/,\s*/).map do |name|
        Tag.find_or_create_by_name_and_project_id(name, project_id)
      end
    end
  end
end
