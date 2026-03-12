class Organization < ApplicationRecord
  belongs_to :address, optional: true

  has_many :people, dependent: :nullify
  has_many :funds, dependent: :destroy
  has_many :messages, as: :messagable, dependent: :destroy

  has_auto_controller
end
