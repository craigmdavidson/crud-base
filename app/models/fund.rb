class Fund < ApplicationRecord
  belongs_to :organization

  money :total_fund, :research_allocation, :operations_expense_allocation, :program_delivery_allocation

  KEY_ATTRIBUTES = [:name, :organization_id, :start_date, :end_date, :total_fund]

  has_auto_controller key_attributes: KEY_ATTRIBUTES, sidebar: { icon: "banknotes" }
  has_nested_auto_controller Organization, key_attributes: KEY_ATTRIBUTES
end
