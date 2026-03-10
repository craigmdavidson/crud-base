class Person < ApplicationRecord
  belongs_to :address, optional: true
  belongs_to :organization, optional: true
  has_many :messages, as: :messagable, dependent: :destroy  

  has_auto_controller after_save_redirect_to: :index

  has_nested_auto_controller Organization,
    permit: [:title, :first_name, :last_name, :email, :telephone]
    
    
  def name
    [first_name, last_name].join(" ")
  end    
end
