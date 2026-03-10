class Comment < ApplicationRecord
  belongs_to :post

  has_nested_auto_controller Post,
    permit: [:body], allow_unauthenticated: [:show, :index]
end
