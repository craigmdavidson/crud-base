class Address < ApplicationRecord
  has_many :people, dependent: :nullify
  has_many :organizations, dependent: :nullify
  has_many :messages, as: :messagable, dependent: :destroy

  has_auto_controller key_attributes: [ :address, :country, :external_id ],
    sidebar: { icon: "map-pin" }


  def formatted_address
    [ address_line_1, address_line_2, city, state_or_province, postal_code, country ].
      compact_blank.join(", ")
  end

  def address
    [ address_line_1, address_line_2, city, state_or_province, postal_code ].
      compact_blank.join(", ")
  end

  def name
    [ address_line_1, city ].join(".. ")
  end
end
