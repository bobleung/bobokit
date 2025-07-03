class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  def sanitised
    {
      id: id,
      email_address: email_address,
      first_name: first_name,
      last_name: last_name
    }
  end
end
