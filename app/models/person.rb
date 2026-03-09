class Person < ApplicationRecord
  belongs_to :address, optional: true
  belongs_to :organization, optional: true
  
  has_crud_controller after_save_redirect_to: :index
  
end
