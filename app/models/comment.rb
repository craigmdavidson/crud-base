class Comment < ApplicationRecord
  belongs_to :post

  has_crud_controller scope: -> { Post },
    permit: [:body], allow_unauthenticated: [:show, :index], sidebar: false
end
