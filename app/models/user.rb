class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :memberships, dependent: :destroy
  has_many :organisations, through: :memberships, source: :entity

  default_scope { where(deactivated: false) }

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  validates :email_address, uniqueness: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  validate :cannot_deactivate_super_admin

  before_create :generate_verification_token

  def sanitised
    {
      id: id,
      email_address: email_address,
      first_name: first_name,
      last_name: last_name,
      email_verified: email_verified?,
      super_admin: super_admin?
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

  def available_entities
    memberships.accepted.joins(:entity).where(organisations: { active: true }).includes(:entity).map(&:entity)
  end

  def pending_invites
    memberships.pending.joins(:entity).where(organisations: { active: true }).includes(:entity)
  end

  def create_context(entity_id = nil)
    UserContext.new(self, entity_id)
  end

  def super_admin?
    super_admin == true
  end

  def active?
    !deactivated?
  end

  def deactivated?
    deactivated == true
  end

  private

  def cannot_deactivate_super_admin
    if deactivated_changed? && deactivated? && super_admin?
      errors.add(:deactivated, "Super admins cannot be deactivated")
    end
  end

  def link_pending_invites!
    # Find all pending invites for this user's email
    pending = Membership.pending.for_email(email_address)

    # Link them to this user and mark as accepted (they can decline later if needed)
    pending.update_all(
      user_id: id,
      invited_email: nil
    )

    pending.count
  end
end
