class RenameFundMoneyColumns < ActiveRecord::Migration[8.0]
  def change
    rename_column :funds, :total_fund, :total_fund_amount
    rename_column :funds, :research_allocation, :research_allocation_amount
    rename_column :funds, :operations_expense_allocation, :operations_expense_allocation_amount
    rename_column :funds, :program_delivery_allocation, :program_delivery_allocation_amount

    add_column :funds, :total_fund_currency, :string, default: "USD"
    add_column :funds, :research_allocation_currency, :string, default: "USD"
    add_column :funds, :operations_expense_allocation_currency, :string, default: "USD"
    add_column :funds, :program_delivery_allocation_currency, :string, default: "USD"
  end
end
