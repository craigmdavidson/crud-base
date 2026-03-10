class CreateFunds < ActiveRecord::Migration[8.0]
  def change
    create_table :funds do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name
      t.string :code
      t.date :start_date
      t.date :end_date
      t.decimal :total_fund, precision: 10, scale: 2
      t.decimal :research_allocation, precision: 10, scale: 2
      t.decimal :operations_expense_allocation, precision: 10, scale: 2
      t.decimal :program_delivery_allocation, precision: 10, scale: 2

      t.timestamps
    end
  end
end
