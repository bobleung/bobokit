# Product Requirements Document: Multi-Entity Permission System

**Version:** 2.1 (Implementation Complete)\
**Date:** July 2025\
**Status:** ✅ IMPLEMENTED

## 1. Executive Summary

### 1.1 Purpose

This document outlines the requirements for implementing a flexible, role-based permission system for a multi-entity platform where users can belong to multiple organisations (Agencies, Clients, and Locum Profiles) with different access levels.

> **Implementation Note:** This system has been fully implemented as of July 2025. This document reflects the exact implementation and all business logic decisions made during development.

### 1.2 Tech Stack

- **Backend:** Rails 8.0 ✅
- **Frontend:** Inertia.js v2 + Svelte 5 ✅
- **Styling:** Tailwind CSS v4 + DaisyUI v5 ✅
- **Database:** SQLite 3 ✅
- **Authentication:** Custom session-based with table-backed sessions ✅
- **Navigation:** Inertia.js Link components with proper method handling ✅

### 1.3 Key Design Decisions

- Single Table Inheritance (STI) for organisations ✅
- Context-based user entity switching ✅
- Session-based authentication with Current thread-local storage ✅
- Entity switching UI with user profile integration ✅
- Soft deletion pattern for organisation deactivation ✅

## 2. Implementation Status

### 2.1 Completed Features ✅

- **User Authentication System** - Session-based with email verification
- **Organisation Management** - Create, edit, view, deactivate organisations
- **Membership System** - Roles (member, admin, owner) with proper permissions
- **Entity Switching** - Seamless context switching between organisations
- **Permission Controls** - Frontend and backend permission validation
- **User Interface** - Responsive design with DaisyUI components
- **Member Management** - Invite, accept, decline, remove members
- **Organisation Deactivation** - Soft deletion with proper access control

### 2.2 Business Logic Implemented

#### 2.2.1 Organisation Types
- **Agency**: Multi-member organisations for staffing agencies
- **Client**: Healthcare facilities that can have parent/child relationships
- **Locum**: Individual professional profiles (single-user entities)

#### 2.2.2 Role-Based Permissions

| Feature | Member | Admin | Owner |
|---------|--------|--------|-------|
| View organisation | ✅ | ✅ | ✅ |
| Edit organisation details | ❌ | ✅ | ✅ |
| Invite members | ❌ | ✅ | ✅ |
| Remove other members | ❌ | ✅ | ✅ |
| Change member roles | ❌ | ✅ | ✅ |
| Leave organisation | ✅ | ❌ | ❌ |
| Remove themselves | ✅ | ❌ | ❌ |
| Deactivate organisation | ❌ | ❌ | ✅ |

#### 2.2.3 Advanced Business Rules

1. **Organisation Creation**: Creator automatically becomes owner with accepted membership
2. **Member Self-Removal**: Members can leave organisations, but admins/owners cannot remove themselves
3. **Deactivation Requirements**: Only owners can deactivate, and only if no other members exist
4. **Context Management**: Users with deactivated entities are automatically logged out of that context
5. **Entity Filtering**: Deactivated organisations are hidden from entity switcher
6. **Invitation Flow**: Email-based invitations with accept/decline functionality

## 3. Data Model (Final Implementation)

### 3.1 Database Schema

```ruby
# Organisations (Single Table Inheritance) ✅
organisations
├── id (bigint, primary key)
├── type (string, not null) # 'Agency', 'Client', 'Locum'
├── name (string, not null)
├── email (string)
├── phone (string)
├── address_line1 (string)
├── address_line2 (string)
├── city (string)
├── county (string)
├── postcode (string)
├── country (string, default: 'GB')
├── metadata (jsonb)
├── parent_id (bigint, foreign key → organisations)
├── code_type (string) # GMC/NMC/HCPC for Locums, facility types for Clients
├── code (string) # License numbers or facility codes
├── note (text)
├── active (boolean, default: true, not null) # ✅ Soft deletion
└── timestamps

# Memberships (User ↔ Organisation relationship) ✅
memberships
├── id (bigint, primary key)
├── user_id (bigint, foreign key → users, nullable for pending invites)
├── entity_id (bigint, foreign key → organisations)
├── role (integer, default: 0) # enum: member(0), admin(1), owner(2)
├── invited_email (string, nullable) # For pending invitations
├── invite_accepted (boolean, default: false)
└── timestamps

# Users ✅
users
├── id (bigint, primary key)
├── email_address (string, not null, unique)
├── password_digest (string, not null)
├── first_name (string, not null)
├── last_name (string, not null)
├── super_admin (boolean, default: false)
├── email_verified_at (timestamp)
├── verification_token (string)
├── verification_token_expires_at (timestamp)
└── timestamps

# Sessions (Table-backed sessions) ✅
sessions
├── id (bigint, primary key)
├── user_id (bigint, foreign key → users)
├── ip_address (string)
├── user_agent (string)
└── timestamps
```

### 3.2 Model Relationships ✅

```ruby
# User Model
class User < ApplicationRecord
  has_secure_password
  has_many :memberships, dependent: :destroy
  has_many :organisations, through: :memberships
  has_many :sessions, dependent: :destroy
  
  def available_entities
    memberships.accepted.joins(:entity)
              .where(organisations: { active: true })
              .includes(:entity).map(&:entity)
  end
  
  def pending_invites
    memberships.pending.joins(:entity)
              .where(organisations: { active: true })
              .includes(:entity)
  end
end

# Organisation Model (STI)
class Organisation < ApplicationRecord
  has_many :memberships, foreign_key: :entity_id, dependent: :destroy
  has_many :users, through: :memberships
  has_many :children, class_name: "Organisation", foreign_key: :parent_id
  belongs_to :parent, class_name: "Organisation", optional: true
  
  scope :active, -> { where(active: true) }
  scope :inactive, -> { where(active: false) }
end

# Membership Model
class Membership < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :entity, class_name: 'Organisation'
  
  enum :role, { member: 0, admin: 1, owner: 2 }
  
  scope :accepted, -> { where(invite_accepted: true) }
  scope :pending, -> { where(invite_accepted: false) }
end
```

## 4. User Interface Implementation

### 4.1 EntitySwitcher Component ✅

**Location**: `/app/frontend/components/EntitySwitcher.svelte`

**Features Implemented**:
- Integrated user profile dropdown with entity switching
- Display format: "Bob (Organisation Name)"
- Right-aligned dropdown to prevent overflow
- Separate navigation for different action types:
  - Link components for GET requests (Profile, Log Out, Manage Entity, Create New Entity)
  - Button components with router.post() for POST requests (Entity switching)
  - Button components with router.post() for invitation actions (Accept/Decline)

**Business Logic**:
- Only shows active organisations
- Automatically updates on context changes
- Handles pending invitations with separate section
- Uses DaisyUI native dropdown behaviour

### 4.2 Organisation Management Pages ✅

#### 4.2.1 Organisation Show Page
**Location**: `/app/frontend/pages/organisations/show.svelte`

**Features**:
- Conditional "Edit Organisation" button (admin/owner only)
- "Leave Organisation" button for members
- Member list with role management
- Invitation system with email-based invites
- Avatar system using DaisyUI standards

#### 4.2.2 Organisation Edit Page
**Location**: `/app/frontend/pages/organisations/edit.svelte`

**Features**:
- Form validation and error handling
- UK-specific address format ("House number and street name", "Flat, building, etc.")
- DaisyUI fieldset components for proper form structure
- Deactivation section with "Danger Zone" styling
- Permission-based deactivation controls

### 4.3 Layout System ✅

**Location**: `/app/frontend/layouts/Layout.svelte`

**Features**:
- Responsive navigation with EntitySwitcher integration
- Flash message display system
- Shared user data via Inertia.js global sharing
- Mobile-responsive design

## 5. Backend Implementation

### 5.1 Authentication System ✅

**Location**: `/app/controllers/concerns/authentication.rb`

**Features**:
- Session-based authentication with table-backed sessions
- Current thread-local storage for user/session data
- Email verification system
- Allow unverified access helper method

### 5.2 Entity Context Management ✅

**Location**: `/app/models/user_context.rb`

**Features**:
- User context creation and validation
- Active entity filtering
- Default entity selection logic
- Context switching validation

**Location**: `/app/controllers/user_context_controller.rb`

**Features**:
- Entity switching endpoint
- Session management
- Context validation and error handling

### 5.3 Organisation Controller ✅

**Location**: `/app/controllers/organisations_controller.rb`

**Actions Implemented**:
- `new` / `create` - Organisation creation with automatic owner membership
- `show` - View organisation with member list
- `edit` / `update` - Edit organisation details (admin/owner only)
- `invite_member` - Send email invitations
- `remove_member` - Remove members (with self-removal for members)
- `change_member_role` - Modify member permissions
- `deactivate` - Soft delete organisations (owner only, no other members)

**Permission Checks**:
- Frontend UI restrictions
- Backend controller validation
- Model-level permission methods

## 6. Business Rules (Final Implementation)

### 6.1 Organisation Creation ✅
1. Any authenticated user can create organisations
2. Creator automatically becomes owner with `invite_accepted: true`
3. Automatic context switching to new organisation
4. Support for all three organisation types (Agency, Client, Locum)

### 6.2 Membership Management ✅
1. **Invitation Flow**:
   - Admin/Owner can invite by email
   - Email-based pending invitations
   - Accept/Decline actions via EntitySwitcher
   - Automatic membership activation on acceptance

2. **Role Management**:
   - Admin/Owner can change member roles
   - Cannot change owner role
   - Cannot change own role

3. **Member Removal**:
   - Admin/Owner can remove other members
   - Members can remove themselves
   - Admins cannot remove themselves
   - Owners cannot be removed

### 6.3 Organisation Deactivation ✅
1. **Requirements**:
   - Only organisation owners can deactivate
   - No other members can exist
   - Must remove all other members first

2. **Effects**:
   - Organisation marked as `active: false`
   - Hidden from entity switcher
   - User context cleared
   - Historical data preserved

3. **UI**:
   - "Danger Zone" section on edit page
   - Clear warning messages
   - Confirmation dialog

### 6.4 Permission Matrix (Final) ✅

| Action | Member | Admin | Owner | Super Admin |
|--------|--------|--------|-------|-------------|
| View organisation | ✅ | ✅ | ✅ | ✅ |
| Edit organisation | ❌ | ✅ | ✅ | ✅ |
| Invite members | ❌ | ✅ | ✅ | ✅ |
| Remove other members | ❌ | ✅ | ✅ | ✅ |
| Change member roles | ❌ | ✅ | ✅ | ✅ |
| Remove self | ✅ | ❌ | ❌ | ✅ |
| Deactivate organisation | ❌ | ❌ | ✅ | ✅ |
| Delete organisation | ❌ | ❌ | ❌ | ✅ |

## 7. Technical Implementation Details

### 7.1 Frontend Architecture ✅

**Framework**: Svelte 5 with Inertia.js v2
- Reactive state management with `$state`, `$derived`, `$props`
- Component-based architecture
- DaisyUI component library integration
- Proper Link vs Button usage for different HTTP methods

**Navigation Patterns**:
- Link components for GET requests only
- Button components with router.get()/post()/patch()/delete() for other methods
- Document.activeElement.blur() for dropdown closing

### 7.2 Backend Architecture ✅

**Framework**: Rails 8.0
- Single Table Inheritance for organisations
- Thread-local current user/session storage
- Inertia.js server-side rendering integration
- Session-based authentication

**Database Patterns**:
- Soft deletion with `active` column
- Polymorphic associations avoided in favour of STI
- Proper indexing for performance
- UK-specific validation patterns

### 7.3 Security Implementation ✅

1. **Authentication**: Session-based with secure cookies
2. **Authorisation**: Multi-layer permission checks (UI + Controller + Model)
3. **Context Validation**: Entity access verified on each request
4. **Input Validation**: Strong parameters and model validations
5. **CSRF Protection**: Rails built-in protection enabled

## 8. Testing Strategy

### 8.1 Manual Testing Completed ✅
- User registration and authentication flows
- Organisation creation for all types
- Entity switching functionality
- Member invitation and management
- Permission enforcement across roles
- Organisation deactivation scenarios
- UI responsiveness and accessibility

### 8.2 Edge Cases Handled ✅
- Deactivated organisation context clearing
- Invalid entity switching attempts
- Self-removal permission logic
- Empty member list scenarios
- Dropdown positioning and overflow

## 9. Future Enhancements

### 9.1 Potential Additions
- Job management system (as originally planned in v1)
- Real-time notifications for invitations
- Bulk member management
- Organisation analytics and reporting
- API endpoints for mobile applications
- Advanced role customisation

### 9.2 Performance Optimisations
- Database query optimisation with proper indexes
- Caching layer for frequently accessed data
- Lazy loading for large member lists
- Background job processing for email invitations

## 10. Deployment Notes

### 10.1 Database Migrations ✅
- All migrations completed and tested
- Proper rollback procedures documented
- Data integrity maintained throughout development

### 10.2 Environment Configuration ✅
- UK-specific defaults (country codes, address formats)
- Email configuration for invitation system
- Session security settings
- Development vs production environment differences

## 11. Lessons Learned

### 11.1 Technical Decisions
1. **DaisyUI Integration**: Using native DaisyUI patterns (avatar-placeholder, fieldset) improved consistency
2. **Inertia Navigation**: Link vs Button distinction critical for proper HTTP method handling
3. **Context Management**: Thread-local storage pattern worked well for user context
4. **Soft Deletion**: Better than hard deletion for maintaining data integrity

### 11.2 UX Decisions
1. **Entity Switcher Integration**: Combining user profile with entity switching improved navigation
2. **Permission Messaging**: Clear error messages essential for user understanding
3. **Confirmation Dialogs**: Critical for destructive actions like leaving/deactivating
4. **Role-Based UI**: Hiding vs disabling based on context and user feedback

## 12. Appendix

### 12.1 File Structure
```
app/
├── controllers/
│   ├── concerns/authentication.rb
│   ├── organisations_controller.rb
│   ├── user_context_controller.rb
│   ├── sessions_controller.rb
│   ├── users_controller.rb
│   └── memberships_controller.rb
├── models/
│   ├── user.rb
│   ├── organisation.rb
│   ├── membership.rb
│   ├── session.rb
│   ├── current.rb
│   └── user_context.rb
├── frontend/
│   ├── components/
│   │   ├── EntitySwitcher.svelte
│   │   ├── Navbar.svelte
│   │   └── Flash.svelte
│   ├── layouts/
│   │   └── Layout.svelte
│   └── pages/
│       ├── organisations/
│       │   ├── new.svelte
│       │   ├── show.svelte
│       │   └── edit.svelte
│       └── users/
│           ├── login.svelte
│           └── register.svelte
```

### 12.2 Key Routes
```ruby
# Authentication
get "login", to: "sessions#new"
get "signup", to: "users#new"
resource :session
resources :users

# Organisation Management
resources :organisations, only: [:new, :create, :show, :edit, :update] do
  member do
    post :invite_member
    delete :remove_member
    patch :change_member_role
    patch :deactivate
  end
end

# Context Switching
post "user/switch_context", to: "user_context#switch_context"

# Membership Actions
resources :memberships, only: [] do
  member do
    post :accept
    post :decline
  end
end
```

### 12.3 Glossary
- **Entity**: An organisation (Agency, Client, or Locum)
- **Context**: The current entity a user is acting as
- **Membership**: The relationship between a user and an entity
- **STI**: Single Table Inheritance (Rails pattern)
- **Soft Deletion**: Marking records as inactive rather than deleting
- **EntitySwitcher**: The UI component for switching between organisations

---

**Document Status**: ✅ Complete - Reflects exact implementation as of July 2025