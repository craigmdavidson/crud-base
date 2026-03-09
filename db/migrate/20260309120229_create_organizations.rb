class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.references :address, null: true, foreign_key: true

      t.timestamps
    end
  end
end
