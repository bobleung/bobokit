class UserContext
  attr_reader :current_user, :current_entity, :current_membership
  
  def initialize(user, entity_id = nil)
    @current_user = user
    return unless user
    
    set_entity(entity_id)
  end
  
  def set_entity(entity_id)
    return unless @current_user
    
    if entity_id
      @current_membership = @current_user.memberships.accepted.joins(:entity).where(organisations: { active: true }).find_by(entity_id: entity_id)
      @current_entity = @current_membership&.entity
    else
      # Default to first available entity
      @current_membership = @current_user.memberships.accepted.joins(:entity).where(organisations: { active: true }).first
      @current_entity = @current_membership&.entity
    end
  end
  
  def switch_entity(entity_id)
    set_entity(entity_id)
    valid?
  end
  
  def valid?
    @current_user && @current_entity && @current_membership
  end
  
  def available_entities
    return [] unless @current_user
    
    @current_user.available_entities
  end
  
  def can_manage_users?
    @current_membership&.can_manage_users? || false
  end
  
  def can_delete_organisation?
    @current_membership&.can_delete_organisation? || false
  end
  
  def role
    @current_membership&.role
  end
  
  def super_admin?
    @current_user&.super_admin?
  end
end