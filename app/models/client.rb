class Client < Organisation
  has_many :child_clients, -> { where(type: 'Client') }, class_name: "Client", foreign_key: :parent_id
  belongs_to :parent_client, class_name: "Client", foreign_key: :parent_id, optional: true
  
  scope :parent_clients, -> { where(parent_id: nil) }
  scope :child_clients, -> { where.not(parent_id: nil) }
  
  def parent_client?
    parent_id.nil?
  end
  
  def child_client?
    !parent_client?
  end
  
  def self.model_name
    Organisation.model_name
  end
end