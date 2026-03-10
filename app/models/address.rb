class Address < ApplicationRecord
  has_auto_controller after_save_redirect_to: :index

  has_many :people, dependent: :nullify
  has_many :organizations, dependent: :nullify
  has_many :messages, as: :messagable, dependent: :destroy  

  def formatted_address
    [
      address_line_1, address_line_2, 
      city, state_or_province, postal_code, country
    ].compact_blank.join(", ")
  end

  def name
    [address_line_1, city].join(".. ")
  end
end
