class CreatePeople < ActiveRecord::Migration[8.0]
  def change
    create_table :people do |t|
      t.string :title
      t.string :first_name
      t.string :last_name
      t.references :address, null: true, foreign_key: true
      t.string :email
      t.string :telephone

      t.timestamps
    end
  end
end
