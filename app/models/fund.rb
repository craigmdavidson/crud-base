class Fund < ApplicationRecord
  belongs_to :organization

  composed_of :total_fund, class_name: "Auto::Money", mapping: [%w[total_fund_amount amount], %w[total_fund_currency currency]], allow_nil: true, converter: :parse
  composed_of :research_allocation, class_name: "Auto::Money", mapping: [%w[research_allocation_amount amount], %w[research_allocation_currency currency]], allow_nil: true, converter: :parse
  composed_of :operations_expense_allocation, class_name: "Auto::Money", mapping: [%w[operations_expense_allocation_amount amount], %w[operations_expense_allocation_currency currency]], allow_nil: true, converter: :parse
  composed_of :program_delivery_allocation, class_name: "Auto::Money", mapping: [%w[program_delivery_allocation_amount amount], %w[program_delivery_allocation_currency currency]], allow_nil: true, converter: :parse

  KEY_ATTRIBUTES = [:name, :organization_id, :start_date, :end_date, :total_fund]

  has_auto_controller key_attributes: KEY_ATTRIBUTES, sidebar: { icon: "banknotes" }
  has_nested_auto_controller Organization, key_attributes: KEY_ATTRIBUTES
end
