# ===================================================================
# USER CONTEXT CONTROLLER
# 
# Handles entity context switching for multi-organisation users.
# Users can belong to multiple organisations (Agency, Client, Locum)
# and switch between them via the entity switcher dropdown.
# 
# ROUTES:
# POST /user/switch_context - Switch current entity context
# 
# RELATED FILES:
# - ApplicationController: load_user_context, switch_entity_context methods
# - UserContext model: Context validation and data holder
# - EntitySwitcher.svelte: Frontend UI component
# ===================================================================
class UserContextController < ApplicationController
  
  # ===================================================================
  # ENTITY SWITCHING ACTION
  # Route: POST /user/switch_context
  # Called by: EntitySwitcher.svelte component
  # ===================================================================
  
  def switch_context
    entity_id = params[:entity_id]

    if switch_entity_context(entity_id)
      Rails.logger.info "██ >> Switched Entity Success"
      flash[:success] = "Switched to #{@current_context.current_entity.display_name}"
      redirect_to root_path
      return
    else
      flash[:error] = "Unable to switch to that entity"
    end

    redirect_back(fallback_location: root_path)
  end
end

# ===================================================================
# USER CONTEXT DATA REFERENCE
# 
# After successful authentication and context loading, the following
# data becomes available in all controllers and views:
# 
# ===================================================================
# 
# AUTHENTICATION DATA (from Session model):
# - Current.user              # => <User object> 
# - Current.user.id           # => 123
# - Current.user.email        # => "john@example.com"
# - Current.user.super_admin? # => true/false
# 
# ===================================================================
# 
# ENTITY CONTEXT DATA (from @current_context):
# 
# CURRENT ENTITY:
# - @current_context.current_entity       # => <Organisation object>
# - @current_context.current_entity.id    # => 456  
# - @current_context.current_entity.name  # => "ABC Agency"
# - @current_context.current_entity.type  # => "Agency", "Client", or "Locum"
# 
# USER'S ROLE IN CURRENT ENTITY:
# - @current_context.role                 # => "member", "admin", or "owner"
# - @current_context.current_membership   # => <Membership object>
# 
# PERMISSIONS IN CURRENT ENTITY:
# - @current_context.can_manage_users?         # => true/false
# - @current_context.can_delete_organisation?  # => true/false
# - @current_context.super_admin?              # => true/false (global)
# 
# AVAILABLE ENTITIES (for switcher dropdown):
# - @current_context.available_entities   # => [<Organisation>, <Organisation>, ...]
# 
# ===================================================================
# 
# FRONTEND ACCESS (via inertia_share in ApplicationController):
# 
# In Svelte components, access via props:
# - user                 # Current.user data
# - currentEntity        # Current entity info  
# - availableEntities    # Entities user can switch to
# - pendingInvites       # Membership invitations awaiting response
# - userContext          # Role and permissions in current entity
# 
# Example in Svelte:
# let { user, currentEntity, userContext } = $props();
# 
# if (userContext.role === 'admin') {
#   // Show admin features
# }
# 
# if (currentEntity.type === 'Agency') {
#   // Show agency-specific features  
# }
# 
# ===================================================================
# 
# CONTROLLER USAGE EXAMPLES:
# 
# # Check user's role in current entity
# if @current_context.role == 'admin'
#   # Allow admin actions
# end
# 
# # Filter data based on current entity type
# case @current_context.current_entity.type
# when 'Agency'
#   @jobs = Job.where(agency: @current_context.current_entity)
# when 'Client'  
#   @jobs = Job.where(client: @current_context.current_entity)
# when 'Locum'
#   @jobs = Job.where(locum: @current_context.current_entity)
# end
# 
# # Check permissions before sensitive actions
# unless @current_context.can_manage_users?
#   redirect_to root_path, alert: "Access denied"
# end
# 
# ===================================================================
