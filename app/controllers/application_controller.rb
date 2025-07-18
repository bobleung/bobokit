class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :load_user_context, if: :authenticated?

  inertia_share do
    {
      user: Current.user&.sanitised,
      currentEntity: @current_context&.current_entity&.as_json(only: [ :id, :name, :type ]),
      availableEntities: @current_context&.available_entities&.as_json(only: [ :id, :name, :type ]) || [],
      pendingInvites: Current.user&.pending_invites&.map { |invite|
        {
          id: invite.id,
          role: invite.role,
          entity: invite.entity.as_json(only: [ :id, :name, :type ])
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

  # ===================================================================
  # ENTITY CONTEXT MANAGEMENT
  # 
  # This application supports multi-entity contexts where users can
  # belong to multiple organisations (Agency, Client, Locum) and switch
  # between them. The current context is stored in session[:current_entity_id]
  # and loaded on every request.
  # ===================================================================

  # Loads user's current entity context on every request
  # Called by: before_action :load_user_context, if: :authenticated?
  # 
  # FLOW:
  # 1. Reads session[:current_entity_id] 
  # 2. Validates user still has access to that entity
  # 3. Auto-corrects session if user lost access (falls back to first available)
  # 4. Sets @current_context for use in controllers/views
  #
  # RESULT: @current_context becomes available with user's role, permissions, entity info
  def load_user_context
    return unless Current.user

    entity_id = session[:current_entity_id]
    @current_context = Current.user.create_context(entity_id)

    # Store the valid entity_id back to session (auto-correction if needed)
    session[:current_entity_id] = @current_context.current_entity&.id
  end

  # Validates and switches user to a different entity context
  # Called by: UserContextController, OrganisationsController, MembershipsController
  # 
  # PARAMETERS:
  # - entity_id: ID of the organisation to switch to
  #
  # RETURNS:
  # - true: Successfully switched, session updated, @current_context refreshed
  # - false: User doesn't have access to that entity, no changes made
  #
  # SECURITY: Validates user has an accepted membership for the target entity
  def switch_entity_context(entity_id)
    return unless Current.user

    @current_context = Current.user.create_context(entity_id)
    if @current_context.valid?
      session[:current_entity_id] = entity_id
      Rails.logger.info "✅ User #{Current.user.id} switched to entity #{entity_id}"
      true
    else
      Rails.logger.warn "❌ User #{Current.user.id} denied access to entity #{entity_id}"
      false
    end
  end

  def require_super_admin
    unless Current.user&.super_admin?
      redirect_to root_path, alert: "Access denied!"
    end
  end
end
