class User < ApplicationRecord
  has_secure_password

  validates :email_address, presence: true, uniqueness: true
  validates :password, length: { minimum: 8 }
  belongs_to :person, optional: true
  has_many :sessions, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :messages, dependent: :destroy

  delegate :name, to: :person, allow_nil: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
end
