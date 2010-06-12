class ProjectLogo < ActiveRecord::Base
  belongs_to :project
  has_attached_file :image,
    :url => lambda { |img|
      project = img.instance.project
      path = "/projects/#{project.to_param}" + "/project_logos/:id/:attachment?style=:style"
      path
    },
    :storage => :database,
    :styles => {
      :medium => '64x64>',
      :large  => '500x500>'
    },
    :processors => [ :cropper ]

  attr_accessor :crop_x, :crop_y, :crop_w, :crop_h
  after_update :reprocess_image, :if => :cropping?

  def cropping?
    !crop_x.blank? && !crop_y.blank? && !crop_w.blank? && !crop_h.blank?
  end

  def image_geometry(style = :original)
    @geometry ||= {}
    @geometry[style] ||= Paperclip::Geometry.from_file(image.to_file(style))
  end

  private

  def reprocess_image
    image.reprocess!
  end
end
