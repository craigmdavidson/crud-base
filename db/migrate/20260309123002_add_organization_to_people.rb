class AddOrganizationToPeople < ActiveRecord::Migration[8.0]
  def change
    add_reference :people, :organization, foreign_key: true
  end
end
