class Message < ApplicationRecord
  belongs_to :user
  belongs_to :messagable, polymorphic: true
  
  before_validation :assign_user

  has_crud_controller scope: -> { Current.user },
    after_save_redirect_to: :parent, sidebar: false
  
  has_crud_controller controller_name: "Organizations::MessagesController",
    scope: -> { Organization }, permit: [:body],
    after_save_redirect_to: :parent, sidebar: false
  
  has_crud_controller controller_name: "People::MessagesController",
    scope: -> { Person }, permit: [:body],
    after_save_redirect_to: :parent, sidebar: false  
  
  private
    def assign_user
      self.user = Current.user unless user.present?
    end
end
