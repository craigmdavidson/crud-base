class Fund < ApplicationRecord
  belongs_to :organization
  
  KEY_ATTRIBUTES = [:name, :organization_id, :start_date, :end_date, :total_fund]  
  
  has_auto_controller after_save_redirect_to: :index, key_attributes: KEY_ATTRIBUTES
  has_nested_auto_controller Organization, key_attributes: KEY_ATTRIBUTES

  

end
