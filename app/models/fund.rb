class Fund < ApplicationRecord
  belongs_to :organization
  
  has_auto_controller after_save_redirect_to: :index  
  
  has_auto_controller controller_name: "Organizations::FundsController",
    scope: -> { Organization }, 
    after_save_redirect_to: :parent,
    sidebar: false
  
end
