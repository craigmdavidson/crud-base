class User < ApplicationRecord
  has_secure_password
  belongs_to :person, optional: true
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :messages, dependent: :destroy

  delegate :name, to: :person, allow_nil: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
