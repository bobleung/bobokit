# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.0 application called "myLocums-dasiy" that uses Inertia.js v2 with Svelte 5 for the frontend, creating a single-page application experience without traditional API endpoints. The application includes session-based user authentication and is styled with Tailwind CSS v4 and DaisyUI components.

## Key Commands

```bash
# Start development server
bin/dev

# Run tests
bin/rails test

# Code quality
bundle exec rubocop
bundle exec brakeman
```

## Architecture

### Frontend Stack
- **Svelte 5** - Frontend framework with runes-based reactivity (`$state`, `$props`, `$derived`)
- **Inertia.js v2** - Seamless Rails-Svelte integration without API endpoints
- **Tailwind CSS v4** - Utility-first CSS framework with DaisyUI components
- **Vite** - Build tool and development server with HMR support

### Backend Stack
- **Rails 8.0** - Main application framework
- **SQLite** - Database (development/test)
- **Solid Queue** - Background job processing
- **Solid Cache** - Database-backed caching
- **Solid Cable** - Database-backed ActionCable

### Key Patterns

#### Inertia.js Integration
Controllers render Inertia responses instead of traditional views:
```ruby
# Instead of render :show
render inertia: 'users/login', props: { errors: {} }
```

Global data sharing via `inertia_share` in ApplicationController:
```ruby
inertia_share do
  {
    user: Current.user&.sanitised,
    flash: { success: flash[:success], error: flash[:error] }
  }
end
```

#### Frontend Architecture
- **Component Organization**: Reusable components in `app/frontend/components/`, page components in `app/frontend/pages/`
- **Layout System**: Default layout (`app/frontend/layouts/Layout.svelte`) automatically applied to all pages
- **Svelte 5 Patterns**: Use `let { prop } = $props()` for props, `$derived()` for reactive values
- **Navigation**: Use Inertia's `<Link>` component for all internal navigation to maintain SPA behavior

#### Authentication System
- Session-based authentication using `app/controllers/concerns/authentication.rb`
- Table-backed sessions (not cookie-based) with `Session` model
- Current user/session stored in `Current` thread-local storage
- User data sanitized via `User#sanitised` method before frontend exposure

## Key Patterns

### Adding New Pages
1. Create Svelte component in `app/frontend/pages/`
2. Add route in `config/routes.rb`
3. Create controller action that renders with `render inertia: 'page_name', props: { data: {} }`

### Svelte 5 Component Patterns
```svelte
<script>
  let { user, errors = {} } = $props();
  const isAuthenticated = $derived(!!user);
</script>
```

## Multi-Entity Permission System

### System Overview
- **Organisation Types**: Agency, Client, Locum (Single Table Inheritance)
- **Role-Based Permissions**: Member, Admin, Owner roles with different capabilities
- **Entity Switching**: Users can belong to multiple organisations and switch context
- **Soft Deletion**: Organisations can be deactivated (preserved for data integrity)

### Data Models

#### Organisations (STI)
```ruby
# Agency, Client, Locum inherit from Organisation
organisations
├── type (string) # 'Agency', 'Client', 'Locum'
├── name, email, phone
├── address fields (UK format)
├── code_type, code # License types/numbers for Locums
├── parent_id # For Client hierarchies
├── active (boolean, default: true) # Soft deletion
└── timestamps
```

#### Memberships
```ruby
memberships
├── user_id, entity_id (organisation)
├── role (enum: member=0, admin=1, owner=2)
├── invited_email # For pending invitations
├── invite_accepted (boolean, default: false)
└── timestamps
```

### Permission Matrix

| Action | Member | Admin | Owner |
|--------|--------|--------|-------|
| View organisation | ✅ | ✅ | ✅ |
| Edit organisation | ❌ | ✅ | ✅ |
| Invite members | ❌ | ✅ | ✅ |
| Remove other members | ❌ | ✅ | ✅ |
| Change member roles | ❌ | ✅ | ✅ |
| Leave organisation | ✅ | ❌ | ❌ |
| Deactivate organisation | ❌ | ❌ | ✅ |

### Key Controllers

#### OrganisationsController
```ruby
# Actions: new, create, show, edit, update, invite_member, remove_member, change_member_role, deactivate
# Permission checks at controller level for admin/owner actions
# Frontend permission checks for UI elements
```

#### UserContextController
```ruby
# Handles entity switching: POST /user/switch_context
# Updates session[:current_entity_id]
# Validates user has access to target entity
```

### Frontend Components

#### EntitySwitcher Component
- Integrated user profile dropdown with entity switching
- Format: "Bob (Organisation Name)"
- Handles pending invitations (Accept/Decline)
- Uses proper Link vs Button patterns for different HTTP methods

#### Navigation Patterns
- **Link components**: GET requests only (Profile, Log Out, Manage Entity)
- **Button components**: POST/PATCH/DELETE requests with router methods
- **Dropdown closing**: Use `document.activeElement.blur()`

### Key Business Rules

#### Organisation Creation
- Creator automatically becomes owner with `invite_accepted: true`
- Automatic context switching to new organisation

#### Membership Management
- Email-based invitations with accept/decline flow
- Members can remove themselves, admins/owners cannot
- Owners cannot be removed

#### Organisation Deactivation
- Only owners can deactivate
- Must remove all other members first
- Marks `active: false` (soft deletion)
- User context cleared, hidden from entity switcher

### Context Management
```ruby
# ApplicationController inertia_share
{
  user: Current.user&.sanitised,
  currentEntity: @current_context&.current_entity,
  availableEntities: @current_context&.available_entities,
  pendingInvites: Current.user&.pending_invites,
  userContext: { role, permissions, super_admin }
}
```

### DaisyUI Integration
- Use native DaisyUI patterns: `avatar-placeholder`, fieldset components
- Button styling: `btn-link` for link-style buttons
- Modal patterns for destructive actions (deactivation)
- Responsive grid layouts with `md:col-span-2` for full-width fields

## Key Implementation Notes

### Flash Messages
- Flash messages shared globally via `inertia_share` in ApplicationController
- Supports Rails conventions (`notice`, `alert`) and semantic names (`success`, `error`)
- Auto-dismiss: success/notice messages auto-hide after 2 seconds
- Flash component at `app/frontend/components/Flash.svelte`

### User Management
- User deactivation system with `deactivated` boolean field and default scope filtering
- Super admin operations use `User.unscoped` to access all users
- Authentication system automatically logs out deactivated users

### Development Patterns
- Inertia props don't need `.as_json` - pass pure Ruby objects
- When adding private methods, verify placement to avoid making public methods private
- Super admin password updates filter empty fields: `update_params.except(:password, :password_confirmation)` when blank