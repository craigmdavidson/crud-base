class Organization < ApplicationRecord
  belongs_to :address
  
  has_crud_controller after_save_redirect_to: :index
end
