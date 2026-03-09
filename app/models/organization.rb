class Organization < ApplicationRecord
  belongs_to :address, optional: true
  has_many :people, dependent: :nullify
  
  has_crud_controller after_save_redirect_to: :index
end
