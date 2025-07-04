class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  
  before_action :load_user_context, if: :authenticated?

  inertia_share do
    {
      user: Current.user&.sanitised,
      currentEntity: @current_context&.current_entity&.as_json(only: [:id, :name, :type]),
      availableEntities: @current_context&.available_entities&.as_json(only: [:id, :name, :type]) || [],
      pendingInvites: Current.user&.pending_invites&.map { |invite| 
        {
          id: invite.id,
          role: invite.role,
          entity: invite.entity.as_json(only: [:id, :name, :type])
        }
      } || [],
      userContext: @current_context ? {
        role: @current_context.role,
        can_manage_users: @current_context.can_manage_users?,
        can_delete_organisation: @current_context.can_delete_organisation?,
        super_admin: @current_context.super_admin?
      } : nil,
      flash: {
        success: flash[:success],
        error: flash[:error],
        notice: flash[:notice],
        alert: flash[:alert]
      }
    }
  end
  
  private
  
  def load_user_context
    return unless Current.user
    
    entity_id = session[:current_entity_id]
    @current_context = Current.user.create_context(entity_id)
    
    # Store the valid entity_id back to session
    session[:current_entity_id] = @current_context.current_entity&.id
  end
  
  def switch_entity_context(entity_id)
    return unless Current.user
    
    @current_context = Current.user.create_context(entity_id)
    if @current_context.valid?
      session[:current_entity_id] = entity_id
      true
    else
      false
    end
  end
end
