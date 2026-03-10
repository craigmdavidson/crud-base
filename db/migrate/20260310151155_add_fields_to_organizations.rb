class AddFieldsToOrganizations < ActiveRecord::Migration[8.0]
  def change
    add_column :organizations, :code, :string
    add_column :organizations, :business_number, :string
    add_column :organizations, :legal_name, :string
    add_column :organizations, :trading_name, :string
  end
end
