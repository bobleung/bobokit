class Membership < ApplicationRecord
  belongs_to :user, optional: true  # Allow null for pending invites
  belongs_to :entity, class_name: 'Organisation'
  
  enum :role, {
    member: 0,
    admin: 1,
    owner: 2
  }
  
  validates :role, presence: true
  validates :invited_email, presence: true, if: -> { user_id.nil? }
  validates :invited_email, format: { with: URI::MailTo::EMAIL_REGEXP }, if: -> { invited_email.present? }
  
  # Ensure either user_id OR invited_email is present, but not both for pending invites
  validate :user_or_email_present
  validate :unique_membership_per_entity
  
  # Scopes
  scope :accepted, -> { where(invite_accepted: true) }
  scope :pending, -> { where(invite_accepted: false) }
  scope :for_email, ->(email) { where(invited_email: email) }
  
  # States
  def pending_invite?
    !invite_accepted && user_id.nil?
  end
  
  def accepted_member?
    invite_accepted && user_id.present?
  end
  
  def can_manage_users?
    accepted_member? && (admin? || owner?)
  end
  
  def can_delete_organisation?
    accepted_member? && owner?
  end
  
  def display_role
    role.humanize
  end
  
  def display_email
    user&.email_address || invited_email
  end
  
  def display_name
    if user
      "#{user.first_name} #{user.last_name}"
    else
      invited_email
    end
  end
  
  def can_be_removed_by?(user)
    return false if role == 'owner'
    
    # Allow members to remove themselves, but not admins
    if self.user == user
      return role == 'member'
    end
    
    true
  end
  
  def can_change_role_to?(new_role)
    return false if role == 'owner'
    %w[member admin].include?(new_role)
  end
  
  def display_data
    {
      id: id,
      role: role,
      invite_accepted: invite_accepted,
      pending_invite: pending_invite?,
      display_name: display_name,
      display_email: display_email,
      user: user&.sanitised
    }
  end
  
  private
  
  def user_or_email_present
    if user_id.blank? && invited_email.blank?
      errors.add(:base, "Either user or invited email must be present")
    end
  end
  
  def unique_membership_per_entity
    # Check for existing membership with same user
    if user_id.present?
      existing = Membership.where(entity_id: entity_id, user_id: user_id)
      existing = existing.where.not(id: id) if persisted?
      if existing.exists?
        errors.add(:user_id, "already has a membership in this organisation")
      end
    end
    
    # Check for existing invitation with same email
    if invited_email.present?
      existing = Membership.where(entity_id: entity_id, invited_email: invited_email)
      existing = existing.where.not(id: id) if persisted?
      if existing.exists?
        errors.add(:invited_email, "already has a pending invitation to this organisation")
      end
    end
  end
end