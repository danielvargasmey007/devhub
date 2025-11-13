# DevHub - Project Management Training Application

## Summary

DevHub is a Ruby on Rails training application demonstrating clean architecture principles, service objects pattern, and Rails engines for domain-driven design.

---

## Architecture

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         DevHub Application                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   Browser    │  │   Turbo/     │  │   Views      │          │
│  │  (User UI)   │◄─┤   Stimulus   │◄─┤  (ERB)       │          │
│  └──────────────┘  └──────────────┘  └──────┬───────┘          │
│                                              │                   │
│  ┌──────────────────────────────────────────▼───────┐           │
│  │            Controllers (Thin Layer)              │           │
│  │  - ProjectsController                            │           │
│  │  - TasksController                               │           │
│  │  - UsersController                               │           │
│  └──────────────────────┬───────────────────────────┘           │
│                         │                                        │
│  ┌──────────────────────▼───────────────────────────┐           │
│  │         Core Engine (Business Logic)             │           │
│  │  ┌────────────────┐  ┌────────────────┐         │           │
│  │  │   Projects     │  │     Tasks      │         │           │
│  │  │   Services     │  │    Services    │         │           │
│  │  ├────────────────┤  ├────────────────┤         │           │
│  │  │ • Creator      │  │ • Creator      │         │           │
│  │  │ • Updater      │  │ • Updater      │         │           │
│  │  │ • Destroyer    │  │ • Destroyer    │         │           │
│  │  │                │  │ • StatusUpdater│         │           │
│  │  └────────────────┘  └────────────────┘         │           │
│  └──────────────────────┬───────────────────────────┘           │
│                         │                                        │
│  ┌──────────────────────▼───────────────────────────┐           │
│  │         Models (Domain Layer)                    │           │
│  │  - Project    - Task    - User    - Activity     │           │
│  └──────────────────────┬───────────────────────────┘           │
│                         │                                        │
│  ┌──────────────────────▼───────────────────────────┐           │
│  │              PostgreSQL Database                 │           │
│  │  • projects  • tasks  • users  • activities      │           │
│  └──────────────────────────────────────────────────┘           │
│                                                                   │
│  ┌──────────────────────────────────────────────────┐           │
│  │         Admin Engine (Read-Only Dashboard)       │           │
│  │  - Recent Projects (last 5)                      │           │
│  │  - Task Statistics (by status)                   │           │
│  └──────────────────────────────────────────────────┘           │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

### Database Schema & Relationships

```
┌──────────────┐         ┌──────────────┐         ┌──────────────┐
│    users     │         │   projects   │         │  activities  │
├──────────────┤         ├──────────────┤         ├──────────────┤
│ id (PK)      │         │ id (PK)      │         │ id (PK)      │
│ name         │         │ name         │         │ record_type  │
│ email        │◄───┐    │ description  │         │ record_id    │
│password_digest│   │    └──────┬───────┘         │ action       │
└──────────────┘   │           │                 │ created_at   │
                   │           │                 └──────────────┘
                   │           │ 1:N                    ▲
                   │           ▼                        │
                   │    ┌──────────────┐               │
                   │    │    tasks     │               │ Polymorphic
                   │    ├──────────────┤               │
                   │    │ id (PK)      │───────────────┘
                   └────│ assignee_type│ (Polymorphic)
                        │ assignee_id  │
                        │ title        │
                        │ description  │
                        │ status       │
                        │ project_id(FK)
                        └──────────────┘
```

### Service Objects Pattern Flow

```
┌─────────────┐     1. HTTP Request      ┌─────────────────┐
│   Browser   │─────────────────────────►│   Controller    │
└─────────────┘                           └────────┬────────┘
                                                   │
                                         2. Instantiate Service
                                                   │
                                          ┌────────▼────────┐
                                          │  Service Object │
                                          │   (Core Engine) │
                                          └────────┬────────┘
                                                   │
                                         3. Execute Business Logic
                                                   │
                        ┌──────────────────────────┼──────────────────────────┐
                        │                          │                          │
                   ┌────▼─────┐           ┌───────▼────────┐        ┌────────▼────────┐
                   │  Update  │           │  Log Activity  │        │  Return Result  │
                   │   Model  │           │  (Audit Trail) │        │  (true/false)   │
                   └──────────┘           └────────────────┘        └─────────┬───────┘
                                                                               │
                                                                    4. Handle Response
                                                                               │
┌─────────────┐     5. Redirect/Render      ┌──────────────────────────────▼─┘
│   Browser   │◄────────────────────────────┤        Controller
└─────────────┘                             └────────────────────────────────┘
```

### Core Engine Structure

```
engines/core/
├── app/
│   └── services/
│       └── core/
│           ├── projects/
│           │   ├── creator.rb      # Create projects + log activity
│           │   ├── updater.rb      # Update projects + log activity
│           │   └── destroyer.rb    # Delete projects + log activity
│           └── tasks/
│               ├── creator.rb         # Create tasks + log activity
│               ├── updater.rb         # Update tasks + log activity
│               ├── status_updater.rb  # Update task status + log activity
│               └── destroyer.rb       # Delete tasks + log activity
└── lib/
    └── core/
        └── engine.rb
```

### Admin Engine Structure

```
engines/admin/
├── app/
│   ├── controllers/
│   │   └── admin/
│   │       └── dashboard_controller.rb  # Metrics & stats
│   └── views/
│       └── admin/
│           └── dashboard/
│               └── index.html.erb       # Dashboard UI
└── config/
    └── routes.rb                        # Mounted at /admin
```