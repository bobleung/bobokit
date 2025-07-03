class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true

  before_create :generate_verification_token

  def sanitised
    {
      id: id,
      email_address: email_address,
      first_name: first_name,
      last_name: last_name,
      email_verified: email_verified?
    }
  end

  def email_verified?
    email_verified_at.present?
  end

  def generate_verification_token
    self.verification_token = SecureRandom.urlsafe_base64(32)
    self.verification_token_expires_at = 24.hours.from_now
  end

  def regenerate_verification_token
    generate_verification_token
    save!
  end

  def verify_email!
    update!(email_verified_at: Time.current, verification_token: nil, verification_token_expires_at: nil)
  end

  def verification_token_valid?
    verification_token.present? && verification_token_expires_at > Time.current
  end
end
