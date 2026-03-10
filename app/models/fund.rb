class Fund < ApplicationRecord
  belongs_to :organization
  
  has_auto_controller after_save_redirect_to: :index  
  
  has_nested_auto_controller Organization

end
