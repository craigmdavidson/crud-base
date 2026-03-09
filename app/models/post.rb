class Post < ApplicationRecord
  belongs_to :user

  has_many :comments

  has_crud_controller scope: -> { Current.user },
    permit: [:title, :body], allow_unauthenticated: [:show, :index], sidebar: true
end
