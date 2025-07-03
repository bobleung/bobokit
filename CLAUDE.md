# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Rails 8.0 application called "myLocums-dasiy" that uses Inertia.js with Svelte for the frontend. The application includes user authentication with sessions and password management.

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
- **Svelte 5** - Frontend framework
- **Inertia.js** - Connects Rails backend to Svelte frontend
- **Tailwind CSS** - Styling framework with DaisyUI components
- **Vite** - Build tool and development server

### Backend Stack
- **Rails 8.0** - Main application framework
- **SQLite** - Database (development/test)
- **Solid Queue** - Background job processing
- **Solid Cache** - Database-backed caching
- **Solid Cable** - Database-backed ActionCable

### Key Patterns

#### Authentication System
- Session-based authentication using `app/controllers/concerns/authentication.rb`
- Users have many sessions (table-backed sessions)
- Current user/session stored in `Current` thread-local storage
- Password reset functionality included

#### Frontend Structure
- Svelte components in `app/frontend/pages/`
- Inertia.js setup in `app/frontend/entrypoints/inertia.js`
- Assets in `app/frontend/assets/`
- Entrypoints in `app/frontend/entrypoints/`

#### Rails Structure
- Standard Rails MVC architecture
- Authentication concern mixed into ApplicationController
- Inertia.js integration for API-less SPA behavior

## File Structure Highlights

```
app/
├── controllers/
│   ├── concerns/authentication.rb    # Authentication logic
│   ├── sessions_controller.rb        # Login/logout
│   └── passwords_controller.rb       # Password reset
├── frontend/
│   ├── pages/                        # Svelte page components
│   ├── entrypoints/                  # Vite entry points
│   └── assets/                       # Static assets
├── models/
│   ├── user.rb                       # User model with has_secure_password
│   ├── session.rb                    # Session model
│   └── current.rb                    # Thread-local current user/session
```

## Development Notes

### Adding New Pages
1. Create Svelte component in `app/frontend/pages/`
2. Add route in `config/routes.rb`
3. Create controller action that renders with Inertia

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