class Membership < ApplicationRecord
  belongs_to :user
  belongs_to :entity, class_name: 'Organisation'
  
  enum :role, {
    member: 0,
    admin: 1,
    owner: 2
  }
  
  validates :user_id, uniqueness: { scope: :entity_id }
  validates :role, presence: true
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  
  def can_manage_users?
    admin? || owner?
  end
  
  def can_delete_organisation?
    owner?
  end
  
  def display_role
    role.humanize
  end
end