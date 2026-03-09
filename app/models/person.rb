class Person < ApplicationRecord
  belongs_to :address, optional: true
  belongs_to :organization, optional: true

  has_crud_controller after_save_redirect_to: :index

  has_crud_controller controller_name: "Organizations::PeopleController",
    scope: -> { Organization },
    permit: [:title, :first_name, :last_name, :email, :telephone],
    after_save_redirect_to: :parent,
    sidebar: false
end
