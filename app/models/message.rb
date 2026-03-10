class Message < ApplicationRecord
  belongs_to :user
  belongs_to :messagable, polymorphic: true
  
  before_validation :assign_user

  has_auto_controller scope: -> { Current.user },
    after_save_redirect_to: :parent, sidebar: false
  
  has_nested_auto_controllers for_parents: [Organization, Person, Address],
    permit: [:body]  

  
  private
    def assign_user
      self.user = Current.user unless user.present?
    end
end
