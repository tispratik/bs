class Tag < ActiveRecord::Base
  belongs_to :taggable, :polymorphic => true
  
  validates_associated :taggable
  validates_presence_of :name
  
  def to_s
    name
  end
end
