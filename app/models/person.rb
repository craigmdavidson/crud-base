class Person < ApplicationRecord
  belongs_to :address, optional: true
  belongs_to :organization, optional: true
  has_many :messages, as: :messagable, dependent: :destroy  

  KEY_ATTRIBUTES = [:full_name, :email, :telephone, :organization_id]

  has_auto_controller after_save_redirect_to: :index, 
    key_attributes: KEY_ATTRIBUTES,
    sidebar: { icon: "users" }

  has_nested_auto_controller Organization,
    permit: [:title, :first_name, :last_name, :email, :telephone, :address_id],
    # i.e. we can change the things that may be modified dependant on the nesting,
    # e.g. in this case the user cannot change the organization.
    key_attributes: KEY_ATTRIBUTES 
    # i.e. we can change the key attributes dependant on the nesting
    
    
  def name
    [first_name, last_name].join(" ")
  end    
  
  def full_name
    [title, first_name, last_name].join(" ")    
  end
end
