class Address < ApplicationRecord
  has_crud_controller after_save_redirect_to: :index

  has_many :people, dependent: :nullify

  def formatted_address
    [
      address_line_1, address_line_2, 
      city, state_or_province, postal_code, country
    ].compact_blank.join(", ")
  end

  alias_method :name, :formatted_address
end
