# Product Requirements Document: Multi-Entity Permission System

**Version:** 2.0\
**Date:** July 2025\

## 1. Executive Summary

### 1.1 Purpose

This document outlines the requirements for implementing a flexible, role-based permission system for a multi-entity platform where users can belong to multiple organisations (Agencies, Clients, and Locum Profiles) with different access levels to shared resources (Jobs).

> **Note:** Although this document focuses on Jobs as a primary resource example, the permission model is designed to support additional resource types (e.g. Invoices, Contracts) in the future.

### 1.2 Tech Stack

- **Backend:** Rails 8
- **Frontend:** Inertia.js + Svelte 5
- **Styling:** Tailwind CSS v4 + DaisyUI v5
- **Database:** sqlLite 3
- **Authorisation:** Pundit gem with custom UserContext

### 1.3 Key Design Decisions

- Single Table Inheritance (STI) for organisations
- Context-based authorisation (users act as different entities)
- Policy-based permission system using Pundit
- Entity switching UI for multi-organisation users

## 2. Goals and Objectives

### 2.1 Business Goals

- Enable users to belong to multiple organisations with different roles
- Support complex permission scenarios for job access and editing
- Maintain clear audit trails and access control
- Scale to support 10-90k organisations

### 2.2 Technical Goals

- Maintainable and extendable permission system
- Clear separation of concerns
- Reusable patterns for future projects
- Performance-optimized queries
- Type-safe, well-tested implementation

### 2.3 Out of Scope

- Social features between organisations
- Real-time collaboration features (for v1)
- Mobile native apps (web-first approach)

## 3. User Stories

### 3.1 Authentication & Context

**US-1: Multi-Entity User**

> As a user, I can belong to multiple organisations (agencies, clients, or as a locum) and switch between them to access different sets of jobs and permissions.

**US-2: Entity Switching**

> As a logged-in user, I can see all my available entities in a dropdown and switch my current context, which immediately updates what I can see and do.

**US-3: Child Membership Management**

> As a user with membership on a parent client company, I can add or remove users (including myself) to its child client companies. Once I have membership in a child, I can switch context to that child organisation to access its jobs.

### 3.2 Agency Stories

**US-4: Agency Job Management**

> As an agency owner/admin, I can create, edit, and delete jobs owned by my agency, and share them with specific clients and locums.

**US-5: Agency Permissions**

> As a member of an **agency** organisation, my access level determines what I can do:
>
> - **Member** – can create, view and manage jobs.
> - **Admin** – everything a Member can do **plus** add/remove users in the agency.
> - **Owner** – everything an Admin can do **plus** delete the entire agency.

### 3.3 Client Stories

### 3.3 Client Stories

**US-6: Client Job Access**

> As a client, I can view jobs shared with my organisation and edit them based on the permission level granted by the agency.

**US-7: Client Job Management**

> As someone belonging to a **client** organisation (Member, Admin or Owner), I can create, view and manage that client’s jobs.
>
> - **Member** – manage jobs only.
> - **Admin** – manage jobs and manage users.
> - **Owner** – manage jobs, manage users, and delete the client organisation.

### 3.4 Locum Stories

### 3.4 Locum Stories

**US-8: Locum Job Interaction**

> As a locum professional, I can view jobs shared with me and add/edit my notes on these jobs (but not edit the main job details unless specifically permitted).

### 3.5 Super Admin Stories

**US-9: Platform Administration**

> As a super admin, I have unrestricted access to all entities and jobs, can manage users, reset passwords, and perform system maintenance.

## 4. System Architecture

### 4.1 Data Model

````ruby
# Organisations (Single Table Inheritance)
#   • **Agency** and **Locum** use all columns except `parent_id` (they never form hierarchies)
#   • **Client** uses every column, including `parent_id`, to support parent/child structures
organisations
├── id (bigint, primary key)
├── type (string, not null) # 'Agency', 'Client', 'Locum'
├── name (string, not null)
├── email (string)
├── phone (string)
├── address_line1 (string, nullable)
├── address_line2 (string, nullable)
├── city (string, nullable)
├── county (string, nullable) # known as state/region in some locales
├── postcode (string, nullable)
├── country (string, nullable) # ISO-3166 alpha‑2
├── metadata (jsonb, nullable) (jsonb, nullable)
├── parent_id (bigint, nullable, foreign key → organisations) # **Client only** – supports parent/child hierarchy
├── code_type (string, nullable) # for clients, used to determine hospitals, prisons, surgeries. For Locums, used to determine GMC, Nurses, PA etc.
├── code (string, nullable) # site codes for clients if applicable, license number for locum, e.g. GMC no.
└── note (string, nullable)

# Memberships (User ↔ Organisation relationship)
memberships
├── id (bigint, primary key)
├── user_id (bigint, foreign key → users)
├── entity_id (bigint, foreign key → organisations)
├── role (integer, default: 0) # enum: member, admin, owner (Locum defaults to owner)
├── active (boolean, default: true)
└── unique index on [user_id, entity_id]

# Jobs
jobs
├── id (bigint, primary key)
├── description (text)
├── owner_type (string, not null) # 'Agency' or 'Client'
├── owner_id (bigint, not null)
└── status (string)

# Job Shares (Organisation ↔ Job relationship)
job_shares
├── id (bigint, primary key)
├── job_id (bigint, foreign key → jobs)
├── entity_id (bigint, foreign key → organisations)
├── permission_level (integer, default: 0) # enum: read_only, can_edit_notes, can_edit, full_access (extensible; additional levels can be added as needed)
└── unique index on [job_id, entity_id]

# Users (standard Rails setup)
users
├── id (bigint, primary key)
├── email (string, not null, unique)
├── encrypted_password (string)
├── super_admin (boolean, default: false)
└── timestamps

### 4.2 Model Hierarchy
### 4.2 Model Hierarchy

```ruby
Organisation (STI base class)
├── Agency
├── Client
└── Locum

ApplicationPolicy (Pundit base)
├── JobPolicy
├── OrganizationPolicy
└── UserPolicy
````

### 4.3 Context Management Flow

```
User Login → Load Memberships → Set/Restore Context → Apply Permissions → Render UI
                                        ↓
                              UserContext Instance
                              ├── current_user
                              ├── current_entity
                              └── current_membership
```

## 5. Detailed Requirements

### 5.1 Authentication & Session Management

**REQ-1:** System must persist user's selected entity context across sessions\
**REQ-2:** System must validate entity access on every context switch\
**REQ-3:** System must handle invalid/expired contexts gracefully

### 5.2 Permission Rules

**REQ-4:** Job visibility rules:

- Super admins see all jobs
- Users see jobs owned by their current entity
- Users see jobs shared with their current entity
- No other jobs are visible

**REQ-5:** Job edit permissions:

- Super admins can edit any job
- Job owners (organisation) can fully edit or delete
- Shared access follows permission\_level:
  - `read_only`: View only
  - `can_edit_notes`: Edit notes field only (Locums)
  - `can_edit`: Edit most fields
  - `full_access`: Edit all fields except ownership

**Role capability matrix (applies to Agency and Client organisations)**

| Role   | Manage jobs | Manage users | Delete organisation |
| ------ | ----------- | ------------ | ------------------- |
| Owner  | ✓           | ✓            | ✓                   |
| Admin  | ✓           | ✓            | —                   |
| Member | ✓           | —            | —                   |

**REQ-6:** Entity creation and membership rules:

- Any signed‑in user can create a new organisation (Agency, Client or Locum). The creator becomes the **Owner** by default.
- Super admins have unrestricted powers: they can create, edit or delete any organisation at any time.
- Users can request access to existing organisations.
- Users with membership on a parent client can add or remove users (including themselves) to its child client companies.

### 5.3 User Interface Requirements

**REQ-7:** Entity Switcher Component

- Visible on all authenticated pages
- Shows current entity name and type
- Dropdown lists all available entities
- Indicates inherited access clearly
- Updates page content immediately on switch

**REQ-8:** Permission-Based UI

- Hide/disable actions based on permissions
- Show clear messaging when access is denied
- Pre-calculate permissions for performance

### 5.4 API Endpoints

```ruby
# Core endpoints needed
POST   /api/auth/login
POST   /api/auth/logout
GET    /api/user/context          # Current context info
POST   /api/user/switch_context   # Switch entity
GET    /api/user/entities         # Available entities

GET    /api/jobs                  # Scoped to current entity
GET    /api/jobs/:id
POST   /api/jobs                  # Create (if permitted)
PATCH  /api/jobs/:id             # Update (if permitted)
DELETE /api/jobs/:id             # Delete (if permitted)

POST   /api/jobs/:id/share       # Share with another entity
DELETE /api/jobs/:id/share/:entity_id # Revoke share
```

##

## 6. Security Considerations

1. **Authentication:** Use Rails' built-in security features
2. **Authorisation:** Every action must go through Pundit
3. **Context Validation:** Verify entity access on each request
4. **SQL Injection:** Use parameterized queries
5. **CSRF Protection:** Enabled by default in Rails
6. **Audit Trail:** Log all permission checks and denials

## 7. Performance Considerations

1. **Database Indexes:**

   - organisations.type
   - memberships.[user\_id, entity\_id]
   - job\_shares.[job\_id, entity\_id]
   - jobs.[owner\_type, owner\_id]

2. **Query Optimization:**

   - Eager load associations
   - Use includes() to prevent N+1
   - Cache user context per request
   - Consider caching permission checks

3. **Frontend Performance:**

   - Lazy load entity lists
   - Cache permission states
   - Minimize API calls on context switch

## 8. Testing Strategy

### 8.1 Unit Tests

- Model validations and methods
- Policy authorisation logic
- UserContext functionality

### 8.2 Integration Tests

- Full permission scenarios
- Entity switching flows
- Job sharing workflows

### 8.3 System Tests

- End-to-end user journeys
- Permission denial scenarios
- Performance benchmarks

## 12. Appendix

### 12.1 Glossary

- **Entity:** An organisation (Agency, Client, or Locum)
- **Context:** The current entity a user is acting as
- **Membership:** The relationship between a user and an entity
- **Job Share:** Permission grant for an entity to access a job
- **STI:** Single Table Inheritance (Rails pattern)
- **Policy:** Authorisation rules for a specific model

