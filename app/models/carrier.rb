class Carrier < ActiveRecord::Base
  
  establish_connection :ref_area
  belongs_to :country
  
end