# Product Requirements Document: Multi-Entity Permission System

**Version:** 1.0  
**Date:** January 2025  
**Status:** Draft

## 1. Executive Summary

### 1.1 Purpose
This document outlines the requirements for implementing a flexible, role-based permission system for a multi-entity platform where users can belong to multiple organizations (Agencies, Clients, and Locum Profiles) with different access levels to shared resources (Jobs).

### 1.2 Tech Stack
- **Backend:** Rails 8
- **Frontend:** Inertia.js + Svelte 5
- **Styling:** Tailwind CSS v4 + DaisyUI v5
- **Database:** PostgreSQL (assumed for JSONB support)
- **Authorization:** Pundit gem with custom UserContext

### 1.3 Key Design Decisions
- Single Table Inheritance (STI) for organizations
- Context-based authorization (users act as different entities)
- Policy-based permission system using Pundit
- Entity switching UI for multi-organization users

## 2. Goals and Objectives

### 2.1 Business Goals
- Enable users to belong to multiple organizations with different roles
- Support complex permission scenarios for job access and editing
- Maintain clear audit trails and access control
- Scale to support 10-90k organizations

### 2.2 Technical Goals
- Maintainable and extendable permission system
- Clear separation of concerns
- Reusable patterns for future projects
- Performance-optimized queries
- Type-safe, well-tested implementation

### 2.3 Non-Goals
- Social features between organizations
- Real-time collaboration features (for v1)
- Mobile native apps (web-first approach)

## 3. User Stories

### 3.1 Authentication & Context

**US-1: Multi-Entity User**
> As a user, I can belong to multiple organizations (agencies, clients, or as a locum) and switch between them to access different sets of jobs and permissions.

**US-2: Entity Switching**
> As a logged-in user, I can see all my available entities in a dropdown and switch my current context, which immediately updates what I can see and do.

**US-3: Inherited Access**
> As a user with access to a parent client company, I automatically have access to all child client companies and can switch to their context.

### 3.2 Agency Stories

**US-4: Agency Job Management**
> As an agency owner/admin, I can create, edit, and delete jobs owned by my agency, and share them with specific clients and locums.

**US-5: Agency Permissions**
> As an agency member, my access level (viewer/editor/admin/owner) determines what actions I can perform on jobs.

### 3.3 Client Stories

**US-6: Client Job Access**
> As a client, I can view jobs shared with my organization and edit them based on the permission level granted by the agency.

**US-7: Client-Owned Jobs**
> As a client admin/owner, I can create and manage jobs directly owned by my client organization.

### 3.4 Locum Stories

**US-8: Locum Job Interaction**
> As a locum professional, I can view jobs shared with me and add/edit my notes on these jobs (but not edit the main job details unless specifically permitted).

### 3.5 Super Admin Stories

**US-9: Platform Administration**
> As a super admin, I have unrestricted access to all entities and jobs, can manage users, reset passwords, and perform system maintenance.

## 4. System Architecture

### 4.1 Data Model

```ruby
# Organizations (Single Table Inheritance)
organizations
├── id (bigint, primary key)
├── type (string, not null) # 'Agency', 'Client', 'LocumProfile'
├── name (string, not null)
├── email (string)
├── phone (string)
├── settings (jsonb, default: {})
├── agency_license_number (string, nullable)
├── commission_rate (decimal(5,2), nullable)
├── parent_id (bigint, nullable, foreign key → organizations)
├── industry (string, nullable)
├── medical_license_number (string, nullable)
├── specialties (text, nullable)
├── available_from (date, nullable)
├── created_at (timestamp)
└── updated_at (timestamp)

# Memberships (User ↔ Organization relationship)
memberships
├── id (bigint, primary key)
├── user_id (bigint, foreign key → users)
├── entity_id (bigint, foreign key → organizations)
├── role (integer, default: 0) # enum: viewer, editor, admin, owner, super_admin
├── active (boolean, default: true)
├── created_at (timestamp)
└── updated_at (timestamp)
└── unique index on [user_id, entity_id]

# Jobs
jobs
├── id (bigint, primary key)
├── title (string, not null)
├── description (text)
├── owner_type (string, not null) # 'Agency' or 'Client'
├── owner_id (bigint, not null)
├── status (string)
├── metadata (jsonb, default: {})
├── created_at (timestamp)
└── updated_at (timestamp)

# Job Shares (Organization ↔ Job relationship)
job_shares
├── id (bigint, primary key)
├── job_id (bigint, foreign key → jobs)
├── entity_id (bigint, foreign key → organizations)
├── permission_level (integer, default: 0) # enum: read_only, can_edit_notes, can_edit, full_access
├── created_at (timestamp)
└── updated_at (timestamp)
└── unique index on [job_id, entity_id]

# Users (standard Rails setup)
users
├── id (bigint, primary key)
├── email (string, not null, unique)
├── encrypted_password (string)
├── [other standard Devise fields]
└── timestamps
```

### 4.2 Model Hierarchy

```ruby
Organization (STI base class)
├── Agency
├── Client
└── LocumProfile

ApplicationPolicy (Pundit base)
├── JobPolicy
├── OrganizationPolicy
└── UserPolicy
```

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

**REQ-1:** System must persist user's selected entity context across sessions  
**REQ-2:** System must validate entity access on every context switch  
**REQ-3:** System must handle invalid/expired contexts gracefully  

### 5.2 Permission Rules

**REQ-4:** Job visibility rules:
- Super admins see all jobs
- Users see jobs owned by their current entity
- Users see jobs shared with their current entity
- No other jobs are visible

**REQ-5:** Job edit permissions:
- Super admins can edit any job
- Job owners (entity) can fully edit/delete
- Shared access follows permission_level:
  - `read_only`: View only
  - `can_edit_notes`: Edit notes field only (Locums)
  - `can_edit`: Edit most fields
  - `full_access`: Edit all fields except ownership

**REQ-6:** Entity creation rules:
- Only super admins can create new organizations
- Users can request access to existing organizations
- Parent client access automatically grants child client access

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

## 6. Implementation Plan

### 6.1 Phase 1: Foundation (Week 1-2)
1. Set up Rails 8 with Inertia and Svelte 5
2. Create database schema and migrations
3. Implement STI models (Organization hierarchy)
4. Set up Pundit and base policies
5. Create UserContext system
6. Implement basic authentication

### 6.2 Phase 2: Core Permissions (Week 3-4)
1. Implement JobPolicy with all rules
2. Create job management controllers
3. Build entity switching functionality
4. Add membership management
5. Create job sharing system
6. Write comprehensive tests

### 6.3 Phase 3: Frontend (Week 5-6)
1. Build entity switcher component
2. Create job list/detail views
3. Implement permission-aware UI components
4. Add job creation/edit forms
5. Build sharing interface
6. Handle error states

### 6.4 Phase 4: Polish & Admin (Week 7-8)
1. Add super admin interface
2. Implement audit logging
3. Performance optimization
4. Security audit
5. Documentation
6. Deployment setup

## 7. Success Criteria

### 7.1 Functional Success
- [ ] Users can belong to multiple organizations
- [ ] Entity switching works seamlessly
- [ ] Permissions are correctly enforced
- [ ] Parent-child client inheritance works
- [ ] Job sharing functions properly
- [ ] Super admin has full access

### 7.2 Technical Success
- [ ] All tests passing (>90% coverage)
- [ ] Page load times <200ms
- [ ] Database queries optimized (no N+1)
- [ ] Clean code with low complexity
- [ ] Comprehensive error handling
- [ ] Security vulnerabilities addressed

### 7.3 User Experience Success
- [ ] Entity switching is intuitive
- [ ] Permissions are transparent
- [ ] Error messages are helpful
- [ ] UI responds quickly
- [ ] Mobile-responsive design

## 8. Security Considerations

1. **Authentication:** Use Rails' built-in security features
2. **Authorization:** Every action must go through Pundit
3. **Context Validation:** Verify entity access on each request
4. **SQL Injection:** Use parameterized queries
5. **CSRF Protection:** Enabled by default in Rails
6. **Audit Trail:** Log all permission checks and denials

## 9. Performance Considerations

1. **Database Indexes:**
   - organizations.type
   - memberships.[user_id, entity_id]
   - job_shares.[job_id, entity_id]
   - jobs.[owner_type, owner_id]

2. **Query Optimization:**
   - Eager load associations
   - Use includes() to prevent N+1
   - Cache user context per request
   - Consider caching permission checks

3. **Frontend Performance:**
   - Lazy load entity lists
   - Cache permission states
   - Minimize API calls on context switch

## 10. Testing Strategy

### 10.1 Unit Tests
- Model validations and methods
- Policy authorization logic
- UserContext functionality

### 10.2 Integration Tests
- Full permission scenarios
- Entity switching flows
- Job sharing workflows

### 10.3 System Tests
- End-to-end user journeys
- Permission denial scenarios
- Performance benchmarks

## 11. Future Enhancements (v2+)

1. **Activity Feed:** Track actions across organizations
2. **Bulk Operations:** Share multiple jobs at once
3. **Permission Templates:** Predefined permission sets
4. **API Access:** OAuth2 for external integrations
5. **Advanced Filtering:** Complex job search
6. **Notifications:** Real-time updates on shared jobs
7. **Mobile Apps:** Native iOS/Android clients

## 12. Appendix

### 12.1 Example Code Snippets

See implementation guide artifact for detailed code examples.

### 12.2 Database Diagrams

See architecture diagram artifacts for visual representations.

### 12.3 Glossary

- **Entity:** An organization (Agency, Client, or LocumProfile)
- **Context:** The current entity a user is acting as
- **Membership:** The relationship between a user and an entity
- **Job Share:** Permission grant for an entity to access a job
- **STI:** Single Table Inheritance (Rails pattern)
- **Policy:** Authorization rules for a specific model

---

**Document maintained by:** Development Team  
**Last updated:** January 2025  
**Next review:** After Phase 2 completion