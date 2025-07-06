# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.0 application called "myLocums-dasiy" that uses Inertia.js v2 with Svelte 5 for the frontend, creating a single-page application experience without traditional API endpoints. The application includes session-based user authentication and is styled with Tailwind CSS v4 and DaisyUI components.

## Development Commands

### Starting the Application
```bash
# Start development server with both Rails and Vite
bin/dev

# Start Rails server only
bin/rails server

# Start Vite development server only
bin/vite dev
```

### Database Management
```bash
# Setup database
bin/rails db:setup

# Run migrations
bin/rails db:migrate

# Reset database
bin/rails db:reset

# Check migration status
bin/rails db:migrate:status
```

### Testing
```bash
# Run tests
bin/rails test

# Run tests with database reset
bin/rails test:db
```

### Asset Management
```bash
# Build frontend assets
bin/rails vite:build

# Clean built assets
bin/rails vite:clobber

# Verify Vite installation
bin/rails vite:verify_install
```

### Code Quality
```bash
# Run RuboCop (Ruby linting)
bundle exec rubocop

# Run Brakeman (security scanner)
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

## File Structure Highlights

```
app/
├── controllers/
│   ├── concerns/authentication.rb    # Authentication logic
│   ├── sessions_controller.rb        # Login/logout
│   ├── passwords_controller.rb       # Password reset
│   └── users_controller.rb           # User registration
├── frontend/
│   ├── components/                   # Reusable Svelte components (Navbar.svelte)
│   ├── layouts/                      # Layout components (Layout.svelte)
│   ├── pages/                        # Svelte page components (auto-resolved by Inertia)
│   ├── entrypoints/                  # Vite entry points (inertia.js)
│   └── assets/                       # Static assets
├── models/
│   ├── user.rb                       # User model with has_secure_password and sanitised method
│   ├── session.rb                    # Session model for table-backed sessions
│   └── current.rb                    # Thread-local current user/session storage
```

## Development Notes

### Adding New Pages
1. Create Svelte component in `app/frontend/pages/` (e.g., `users/profile.svelte`)
2. Add route in `config/routes.rb`
3. Create controller action that renders with `render inertia: 'users/profile', props: { data: {} }`

### Svelte 5 Component Patterns
```svelte
<script>
  import { Link } from '@inertiajs/svelte';
  
  let { user, errors = {} } = $props();
  
  const isAuthenticated = $derived(!!user);
</script>

<!-- Use Link for internal navigation -->
<Link href="/profile" class="btn">Profile</Link>
```

### Data Flow
- Controllers pass data via `props:` in `render inertia:`
- Global data shared via `inertia_share` in ApplicationController
- Access shared data in components via props from layout

### Database Changes
- Use `bin/rails generate migration` for schema changes
- Run `bin/rails db:migrate` after creating migrations

### Frontend Dependencies
- Use `npm install` to add new frontend packages
- Frontend dependencies are in `package.json`

### Deployment
- Application is configured for Kamal deployment
- Uses Thruster for HTTP acceleration
- Dockerfile included for containerization

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

## Memories

### Flash Message Implementation
- Implemented flash messages within the Inertia.js integration
- Flash messages are shared globally via `inertia_share` in ApplicationController
- Can access flash messages in frontend components through shared props
- Supports `success` and `error` flash message types

### Email Verification and Access Control
- Added email verification flow to enhance user authentication
- Implemented `allow_unverified_access` helper method to manage user access based on email verification status

### Inertia Props Passing
- Passing props to inertia in controllers doesn't need .as_json, it can be as pure Ruby object. Default to this.

### Multi-Entity System Implementation
- Built comprehensive role-based permission system with STI organisations
- Implemented entity switching with proper context management
- Added member invitation system with email-based workflow
- Soft deletion pattern for organisation deactivation
- Frontend permission enforcement with backend validation layers

### User Deactivation System
- Added `deactivated` boolean field to users table with default scope filtering
- Default scope `where(deactivated: false)` ensures only active users returned in normal queries
- Super admin controllers use `User.unscoped` to access all users including deactivated
- Authentication system automatically logs out deactivated users and destroys sessions
- Validation prevents super admins from being deactivated
- Frontend visual indicators (strikethrough) for deactivated users in admin interface

### Enhanced Flash Message System
- ApplicationController `inertia_share` supports both Rails conventions and semantic names:
  ```ruby
  flash: {
    success: flash[:success],
    error: flash[:error], 
    notice: flash[:notice],
    alert: flash[:alert]
  }
  ```
- Auto-dismiss functionality: success/notice messages auto-hide after 2 seconds
- Error/alert messages persist until manually dismissed
- Enhanced styling with shadows and subtle animations
- Flash component located at `app/frontend/components/Flash.svelte`

### Super Admin User Management
- Complete user CRUD operations via SuperAdminController
- User deletion functionality with confirmation modal
- Visual management interface with master-detail layout
- All super admin operations use `User.unscoped` to manage both active and deactivated users