class Organisation < ApplicationRecord
  has_many :memberships, foreign_key: :entity_id, dependent: :destroy
  has_many :users, through: :memberships
  has_many :children, class_name: "Organisation", foreign_key: :parent_id, dependent: :destroy
  belongs_to :parent, class_name: "Organisation", optional: true

  validates :name, presence: true
  validates :type, presence: true
  validates :type, inclusion: { in: %w[Agency Client Locum] }

  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
  scope :agencies, -> { where(type: "Agency") }
  scope :clients, -> { where(type: "Client") }
  scope :locums, -> { where(type: "Locum") }

  def display_name
    "#{name} (#{type})"
  end

  def agency?
    type == "Agency"
  end

  def client?
    type == "Client"
  end

  def locum?
    type == "Locum"
  end

  # Specifically added because STI tables automatically omit "type" by default.
  def as_json(options = {})
    super(options).merge(type: type)
  end
  
  def can_have_members?
    type != 'Locum'
  end
  
  def members_data
    memberships.includes(:user).map(&:display_data)
  end
end
