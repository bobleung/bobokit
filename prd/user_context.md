# User Context Management

## Overview

The user context system allows users to act on behalf of different organisations they belong to. Since users can be members of multiple organisations (agencies, clients, or locums), every action must be performed within a specific organisational context.

## Core Concept

**User Context = User + Current Organisation**

When a user performs any action on the platform, the system needs to know:
1. **Who** is performing the action (the authenticated user)
2. **On behalf of which organisation** they are acting (their current context)

## Storage Mechanism

### Session-Based Storage
The current organisation context is stored in the Rails session:

```ruby
session[:current_entity_id] = organisation_id
```

**Benefits of session storage:**
- Persists across browser requests and page refreshes
- Browser-specific (different tabs can have different contexts)
- Secure (server-side storage, not exposed to client)
- Automatic cleanup when session expires

## Implementation Details

### Context Loading (`ApplicationController`)

Every authenticated request loads the user context:

```ruby
# app/controllers/application_controller.rb
def load_user_context
  return unless Current.user

  entity_id = session[:current_entity_id]
  @current_context = Current.user.create_context(entity_id)

  # Store the valid entity_id back to session
  session[:current_entity_id] = @current_context.current_entity&.id
end
```

**Key behaviours:**
- Runs on every request for authenticated users
- Validates the stored entity ID is still valid
- Falls back to user's first available organisation if invalid
- Updates session with corrected entity ID

### Context Switching (`UserContextController`)

Users can switch between organisations they belong to:

```ruby
# app/controllers/user_context_controller.rb
def switch_context
  entity_id = params[:entity_id]
  
  if switch_entity_context(entity_id)
    flash[:success] = "Switched to #{@current_context.current_entity.display_name}"
    redirect_to root_path
  else
    flash[:error] = "Unable to switch to that entity"
    redirect_back(fallback_location: root_path)
  end
end
```

**Security validation:**
- Verifies user belongs to the target organisation
- Only switches if membership is valid and accepted
- Provides user feedback on success/failure

### UserContext Model

The business logic for context management:

```ruby
# app/models/user_context.rb
class UserContext
  def initialize(user, entity_id = nil)
    @user = user
    @current_entity = find_valid_entity(entity_id)
  end

  private

  def find_valid_entity(entity_id)
    # Find specific entity if provided and user has access
    # Otherwise fall back to first available entity
  end
end
```

## Frontend Integration

### Global Context Sharing

Context information is automatically shared with the frontend via Inertia:

```ruby
# app/controllers/application_controller.rb
inertia_share do
  {
    user: Current.user&.sanitised,
    currentEntity: @current_context&.current_entity,
    availableEntities: @current_context&.available_entities,
    userContext: {
      role: @current_context.role,
      can_manage_users: @current_context.can_manage_users?,
      can_delete_organisation: @current_context.can_delete_organisation?,
      super_admin: @current_context.super_admin?
    }
  }
end
```

### Entity Switcher Component

The frontend provides an entity switcher in the user profile dropdown:

```svelte
<!-- app/frontend/components/EntitySwitcher.svelte -->
<!-- Displays current context and available organisations -->
<!-- Handles switching via POST requests to UserContextController -->
```

## Context Validation

### Three-Layer Security

Every request goes through validation:

1. **User Authentication**: Is the user logged in?
2. **Organisation Membership**: Does the user belong to the target organisation?
3. **Action Permissions**: Does the user's role allow the requested action?

### Automatic Correction

The system automatically handles invalid contexts:
- Expired memberships → Switch to valid organisation
- Deactivated organisations → Switch to active organisation  
- Removed from organisation → Switch to remaining organisation
- No valid organisations → Clear context (rare edge case)

## Usage Patterns

### In Controllers

```ruby
class JobsController < ApplicationController
  before_action :set_jobs_scope

  def index
    @jobs = @jobs_scope.all
    # Jobs are already filtered by Current.entity
  end

  private

  def set_jobs_scope
    @jobs_scope = Job.for_organisation(Current.entity)
  end
end
```

### In Models

```ruby
class Job < ApplicationRecord
  scope :for_organisation, ->(org) {
    case org.type.downcase
    when 'agency' then where(agency: org)
    when 'client' then where(client: org)
    when 'locum' then where(locum: org)
    end
  }
end
```

## Session Lifecycle

### Login Flow
1. User authenticates
2. System loads their available organisations
3. Sets context to their last active organisation (from session)
4. If no previous session, defaults to first available organisation

### Multi-Browser Support
- Each browser/tab maintains independent context
- User can be "ClientA" in one browser, "AgencyB" in another
- Context switches only affect the current browser session

### Session Expiry
- When session expires, context is lost
- Next login will default to first available organisation
- Previous context is not remembered across sessions (by design)

## Error Handling

### Invalid Context Scenarios
- User removed from organisation → Auto-switch to valid organisation
- Organisation deactivated → Auto-switch to active organisation
- Malicious entity_id provided → Ignored, falls back to valid entity

### Graceful Degradation
- If no valid organisations exist, user can still access profile/settings
- System prevents actions requiring organisational context
- Clear error messages guide user to resolve membership issues

## Security Considerations

### Context Tampering Prevention
- Entity IDs validated on every request
- User membership checked before context switch
- Session stored server-side, not in cookies/localStorage

### Permission Isolation
- Each organisation context has isolated permissions
- No cross-organisation data leakage
- Audit trail maintains context for all actions

This system ensures users can seamlessly work across multiple organisations while maintaining strict security boundaries and clear context awareness.