class Filter < ActiveRecord::Base

  default_scope :order => :sort_order
  
  def disp_name
  "<u>" + display_name + "</u>:"
  end
  
  def get_params
    FilterParams.all(:conditions => { :filter_param => filter_param })
  end
  
  def self.get_filter(page)
    if page.nil?
      return ""
    end
    if page.filter_name.blank?
      return ""
    end
    return find_all_by_filter_name(page.filter_name)
  end
  
end
