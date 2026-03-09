class CreateAddresses < ActiveRecord::Migration[8.0]
  def change
    create_table :addresses do |t|
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state_or_province
      t.string :postal_code
      t.string :country
      t.string :external_id

      t.timestamps
    end
  end
end
