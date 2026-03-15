class RenameFundMoneyColumns < ActiveRecord::Migration[8.0]
  def change
    change_table :funds do |t|
      t.remove :total_fund, type: :decimal, precision: 10, scale: 2
      t.remove :research_allocation, type: :decimal, precision: 10, scale: 2
      t.remove :operations_expense_allocation, type: :decimal, precision: 10, scale: 2
      t.remove :program_delivery_allocation, type: :decimal, precision: 10, scale: 2

      t.money :total_fund
      t.money :research_allocation
      t.money :operations_expense_allocation
      t.money :program_delivery_allocation
    end
  end
end
