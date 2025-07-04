class Locum < Organisation
  validates :parent_id, absence: true
  
  def self.model_name
    Organisation.model_name
  end
end