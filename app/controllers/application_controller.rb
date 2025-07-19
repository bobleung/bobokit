class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :load_user_context, if: :authenticated?

  # ===================================================================
  # THIS HAPPENS ON EVERY AUTHENTICATED REQUEST
  #
  # 1. Decrypt session_id cookie sent by browser (no DB call)
  # 2. Look up Session record by session_id (1 DB call)
  # 3. Look up User record to check if deactivated (1 DB call)
  # 4. Access session.user for Current.user (1 DB call if not cached)
  # 5. Decrypt Rails session cookie to get entity_id (no DB call)
  # 6. Validate user still belongs to entity_id (1 DB call to memberships)
  # 7. Set @current_context and update session cookie with corrected entity_id
  #    (auto-corrects if user lost access, sets to first available entity)
  #
  # TOTAL: 4 DB calls per authenticated request
  # - 3 for authentication (session lookup + user lookup + user association)
  # - 1 for entity context validation
  #
  # These objects become globally available for the request:
  #
  # - Current.user (User model with properties):
  #   - .id, .email_address, .password_digest, .first_name, .last_name
  #   - .super_admin?, .active?, .deactivated?, .email_verified?
  #   - .memberships, .available_entities, .pending_invites
  #
  # - @current_context (UserContext object with properties):
  #   - .current_user (User object)
  #   - .current_entity (Organisation object: .id, .name, .type, .active)
  #   - .current_membership (Membership object: .role, .invite_accepted)
  #   - .role ("member"/"admin"/"owner")
  #   - .can_manage_users?, .can_delete_organisation?, .super_admin?
  #   - .available_entities
  #   - .valid? (checks if user has complete entity context)
  # ===================================================================

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

  # If user is logged in, the check/ set their context

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
