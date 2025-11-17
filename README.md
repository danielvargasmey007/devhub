# DevHub - Project Management Training Application

## Summary

DevHub is a Ruby on Rails training application demonstrating clean architecture principles, service objects pattern, and Rails engines for domain-driven design.

---

## Architecture

### High-Level System Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                         DevHub Application                     │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐          │
│  │   GraphQL    │  │  GraphiQL    │  │   Admin      │          │
│  │   Clients    │◄─┤   IDE        │  │  Dashboard   │          │
│  └──────┬───────┘  └──────────────┘  └──────────────┘          │
│         │                                                      │
│  ┌──────▼───────────────────────────────────────────┐          │
│  │        GraphQL Controller (/graphql)             │          │
│  │  - Query                                         │          │
│  │  - Mutation                                      │          │
│  │  - Error handling                                │          │
│  └──────────────────────┬───────────────────────────┘          │
│                         │                                      │
│  ┌──────────────────────▼──────────────────────────┐           │
│  │         GraphQL Schema (DevhubSchema)           │           │
│  │  ┌────────────────┐  ┌────────────────┐         │           │
│  │  │     Query      │  │    Mutations   │         │           │
│  │  │     Types      │  │                │         │           │
│  │  ├────────────────┤  ├────────────────┤         │           │
│  │  │ • projects     │  │ • createProject│         │           │
│  │  │ • project(id)  │  │ • updateProject│         │           │
│  │  │ • tasks        │  │ • deleteProject│         │           │
│  │  │ • task(id)     │  │ • createTask   │         │           │
│  │  │                │  │ • updateTask   │         │           │
│  │  │                │  │ • updateTaskStatus│      │           │
│  │  │                │  │ • deleteTask   │         │           │
│  │  └────────────────┘  └────────────────┘         │           │
│  └──────────────────────┬──────────────────────────┘           │
│                         │                                      │
│  ┌──────────────────────▼──────────────────────────┐           │
│  │         Core Engine (Business Logic)            │           │
│  │  ┌────────────────┐  ┌────────────────┐         │           │
│  │  │   Projects     │  │     Tasks      │         │           │
│  │  │   Services     │  │    Services    │         │           │
│  │  ├────────────────┤  ├────────────────┤         │           │
│  │  │ • Creator      │  │ • Creator      │         │           │
│  │  │ • Updater      │  │ • Updater      │         │           │
│  │  │ • Destroyer    │  │ • Destroyer    │         │           │
│  │  │                │  │ • StatusUpdater│◄────┐   │           │
│  │  └────────────────┘  └────────────────┘     │   │           │
│  └─────────────────────────────────────────────┼───┘           │
│                                                │               │
│  ┌─────────────────────────────────────────────▼───┐           │
│  │         Background Jobs (Sidekiq)               │           │
│  │  ┌────────────────────────────────────┐         │           │
│  │  │    ActivityLoggerJob               │         │           │
│  │  │  • Async activity logging          │         │           │
│  │  │  • Task status change tracking     │         │           │
│  │  └────────────────────────────────────┘         │           │
│  └──────────────────────┬───────────────────────────┘          │
│                         │                                      │
│  ┌──────────────────────▼───────────────────────────┐          │
│  │         Models (Domain Layer)                    │          │
│  │  - Project    - Task    - User    - Activity     │          │
│  └──────────────────────┬───────────────────────────┘          │
│                         │                                      │
│  ┌──────────────────────▼───────────────────────────┐          │
│  │              PostgreSQL Database                 │          │
│  │  • projects  • tasks  • users  • activities      │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                │
│  ┌──────────────────────────────────────────────────┐          │
│  │              Redis (Job Queue)                   │          │
│  │  • Sidekiq job queue                             │          │
│  │  • Background job processing                     │          │
│  └──────────────────────────────────────────────────┘          │
│                                                                │
└────────────────────────────────────────────────────────────────┘
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
                        │ status       │ (pending, in_progress, completed, archived)
                        │ project_id(FK)
                        └──────────────┘
```

### API Flow

```
┌─────────────┐     1. GraphQL Query      ┌─────────────────┐
│   Client    │─────────────────────────►│  GraphQL Ctrl    │
│ (GraphiQL)  │                           └────────┬────────┘
└─────────────┘                                    │
                                         2. Parse & Execute Query
                                                   │
                                          ┌────────▼────────┐
                                          │  DevhubSchema   │
                                          │  (Query/Mutation)│
                                          └────────┬────────┘
                                                   │
                                         3. Resolve Fields
                                                   │
                        ┌──────────────────────────┼──────────────────────────┐
                        │                          │                          │
                   ┌────▼─────┐           ┌───────▼────────┐        ┌────────▼────────┐
                   │  Call    │           │  Execute       │        │  Return         │
                   │ Service  │           │  Business      │        │  GraphQL        │
                   │ Objects  │           │  Logic         │        │  Response       │
                   └────┬─────┘           └───────┬────────┘        └─────────────────┘
                        │                         │
                        │ (StatusUpdater)         │
                        ▼                         │
              ┌─────────────────┐                │
              │ ActivityLogger  │                │
              │ Job.perform_later│               │
              └────────┬────────┘                │
                       │                          │
              4. Enqueue Background Job           │
                       │                          │
              ┌────────▼────────┐                │
              │     Sidekiq     │                │
              │   (Redis Queue) │                │
              └────────┬────────┘                │
                       │                          │
              5. Process Job Asynchronously       │
                       │                          │
              ┌────────▼────────┐                │
              │ Create Activity │                │
              │     Record      │                │
              └─────────────────┘                │
                                                  │
┌─────────────┐     6. Return Response    ┌──────▼───────────────────┘
│   Client    │◄────────────────────────────  GraphQL Controller
│ (GraphiQL)  │
└─────────────┘
```

---

## Technology Stack

- **Ruby 3.3.10**
- **Rails 8.1.1**
- **PostgreSQL** - Primary database
- **GraphQL 2.5.14** - API query language
- **GraphiQL Rails 1.10** - Interactive GraphQL IDE
- **Sidekiq 7.3.9** - Background job processing
- **Redis 5.4** - Sidekiq backend & caching
- **Turbo & Stimulus** - Frontend interactivity
- **BCrypt** - Password encryption

---

##  Project Structure

```
devhub/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   └── graphql_controller.rb           # GraphQL endpoint
│   ├── graphql/
│   │   ├── devhub_schema.rb                # Main GraphQL schema
│   │   ├── types/
│   │   │   ├── base_*.rb                   # Base GraphQL types
│   │   │   ├── query_type.rb               # GraphQL queries
│   │   │   ├── mutation_type.rb            # GraphQL mutations
│   │   │   ├── project_type.rb             # Project GraphQL type
│   │   │   ├── task_type.rb                # Task GraphQL type
│   │   │   ├── user_type.rb                # User GraphQL type
│   │   │   └── task_status_enum.rb         # Task status enum
│   │   └── mutations/
│   │       ├── base_mutation.rb
│   │       ├── projects/
│   │       │   ├── create_project.rb
│   │       │   ├── update_project.rb
│   │       │   └── delete_project.rb
│   │       └── tasks/
│   │           ├── create_task.rb
│   │           ├── update_task.rb
│   │           ├── update_task_status.rb   # Triggers Sidekiq job
│   │           └── delete_task.rb
│   ├── jobs/
│   │   ├── application_job.rb
│   │   └── activity_logger_job.rb          # Async activity logging
│   └── models/
│       ├── project.rb
│       ├── task.rb
│       ├── user.rb
│       └── activity.rb
├── engines/
│   ├── core/
│   │   └── app/services/core/
│   │       ├── projects/
│   │       │   ├── creator.rb
│   │       │   ├── updater.rb
│   │       │   └── destroyer.rb
│   │       └── tasks/
│   │           ├── creator.rb
│   │           ├── updater.rb
│   │           ├── status_updater.rb       # Updated for async logging
│   │           └── destroyer.rb
│   └── admin/
│       └── app/controllers/admin/
│           └── dashboard_controller.rb
├── config/
│   ├── routes.rb                           # GraphQL routes
│   ├── application.rb                      # Sidekiq adapter config
│   ├── sidekiq.yml                         # Sidekiq queue config
│   └── initializers/
│       └── sidekiq.rb                      # Redis configuration
└── Gemfile
```

---

## Getting Started

### Prerequisites

- Ruby 3.3.10
- PostgreSQL 14+
- Redis 6+ (for Sidekiq)
- Bundler 2.5+

### Installation

1. **Clone the repository:**
   ```bash
   git clone <repository-url>
   cd devhub
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Setup database:**
   ```bash
   rails db:create
   rails db:migrate
   ```

4. **Install Redis (if not already installed):**
   - **Windows:** https://github.com/microsoftarchive/redis/releases
   - **macOS:** `brew install redis`
   - **Linux:** `sudo apt-get install redis-server`

---

## Running the Application

You need to run **3 separate processes**:

### 1. Start Redis Server
```bash
redis-server
```

### 2. Start Sidekiq Worker
Open a new terminal:
```bash
bundle exec sidekiq
```

### 3. Start Rails Server
Open another terminal:
```bash
rails server
```

---

## Access Points

- **GraphiQL IDE:** http://localhost:3000/graphiql
- **GraphQL API Endpoint:** http://localhost:3000/graphql (POST)
- **Admin Dashboard:** http://localhost:3000/admin
- **Root Path:** http://localhost:3000/ (redirects to GraphiQL in dev)

---

## GraphQL API Documentation

### Queries

#### Get All Projects
```graphql
query {
  projects {
    id
    name
    description
    tasks {
      id
      title
      status
    }
  }
}
```

#### Get Single Project
```graphql
query {
  project(id: "1") {
    id
    name
    description
    tasks {
      id
      title
      status
    }
  }
}
```

#### Get All Tasks
```graphql
query {
  tasks {
    id
    title
    description
    status
    project {
      name
    }
    assignee {
      name
      email
    }
  }
}
```

#### Get Tasks by Project
```graphql
query {
  tasks(projectId: "1") {
    id
    title
    status
  }
}
```

#### Get Single Task
```graphql
query {
  task(id: "1") {
    id
    title
    description
    status
  }
}
```

---

### Mutations

#### Create Project
```graphql
mutation {
  createProject(input: {
    name: "My Project",
    description: "Project description"
  }) {
    project {
      id
      name
      description
    }
    errors
  }
}
```

#### Update Project
```graphql
mutation {
  updateProject(input: {
    id: "1",
    name: "Updated Name"
  }) {
    project {
      id
      name
    }
    errors
  }
}
```

#### Delete Project
```graphql
mutation {
  deleteProject(input: { id: "1" }) {
    success
    errors
  }
}
```

#### Create Task
```graphql
mutation {
  createTask(input: {
    projectId: "1",
    title: "Task Title",
    description: "Task description",
    status: PENDING
  }) {
    task {
      id
      title
      status
    }
    errors
  }
}
```

#### Update Task
```graphql
mutation {
  updateTask(input: {
    id: "1",
    title: "Updated Title"
  }) {
    task {
      id
      title
    }
    errors
  }
}
```

#### Update Task Status (Triggers Background Job!)
```graphql
mutation {
  updateTaskStatus(input: {
    id: "1",
    status: IN_PROGRESS
  }) {
    task {
      id
      title
      status
    }
    errors
  }
}
```

**Available Status Values:**
- `PENDING`
- `IN_PROGRESS`
- `COMPLETED`
- `ARCHIVED`

#### Delete Task
```graphql
mutation {
  deleteTask(input: { id: "1" }) {
    success
    errors
  }
}
```

---

## Background Jobs

### ActivityLoggerJob

Asynchronously logs activity when a task status changes.

**Trigger:**
- Automatically triggered by `Core::Tasks::StatusUpdater`
- Runs via Sidekiq when `updateTaskStatus` mutation is called

**Example Activity:**
```ruby
Activity.create!(
  record: task,
  action: "status_changed_from_pending_to_in_progress"
)
```

**Monitoring:**
Watch Sidekiq terminal for job processing:
```
ActivityLoggerJob: Logged activity for Task #1: status_changed_from_pending_to_in_progress
```

**Verify in Rails Console:**
```ruby
rails console
> Activity.last
> Activity.where(record_type: 'Task', record_id: 1)
```

---

## Testing

### Testing GraphQL API

1. Open GraphiQL: http://localhost:3000/graphiql
2. Use the interactive editor to run queries and mutations
3. Check the "Docs" panel for schema documentation

### Testing Background Jobs

1. Ensure Redis and Sidekiq are running
2. Execute `updateTaskStatus` mutation in GraphiQL
3. Watch Sidekiq terminal for job processing logs
4. Verify Activity records in Rails console

---

## Architecture Patterns

### Service Objects Pattern

All business logic is encapsulated in service objects:

```ruby
# Usage in GraphQL mutation
service = Core::Projects::Creator.new(project_params)

if service.call
  { project: service.project, errors: [] }
else
  { project: nil, errors: service.errors }
end
```

**Benefits:**
- Thin controllers/resolvers
- Testable business logic
- Consistent activity logging
- Transaction management

### Rails Engines

**Core Engine:**
- Contains all business logic services
- Isolated namespace: `Core::`
- Reusable across applications

**Admin Engine:**
- Read-only dashboard
- Isolated namespace: `Admin::`
- Mounted at `/admin`

---

## Database Activity Logging

Every create, update, delete, and status change operation logs an activity:

**Activity Model:**
```ruby
class Activity < ApplicationRecord
  belongs_to :record, polymorphic: true

  scope :recent, -> { order(created_at: :desc).limit(20) }
  scope :for_record, ->(record) { where(record: record) }
end
```

**Activity Actions:**
- `"created"` - Record created
- `"updated"` - Record updated
- `"destroyed"` - Record deleted
- `"status_changed_from_X_to_Y"` - Task status change (async via Sidekiq)

---

## Configuration

### Sidekiq Configuration

**Redis URL:**
```ruby
# config/initializers/sidekiq.rb
Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch("REDIS_URL", "redis://localhost:6379/0") }
end
```

**Queue Configuration:**
```yaml
# config/sidekiq.yml
:concurrency: 5
:max_retries: 3
:queues:
  - default
```

**ActiveJob Adapter:**
```ruby
# config/application.rb
config.active_job.queue_adapter = :sidekiq
```

---

## Development

### Running Tests
```bash
rails test
```

### Code Quality
```bash
# Rubocop
rubocop

# Brakeman (security)
brakeman

# Bundler Audit
bundle audit
```

### Rails Console
```bash
rails console
```

### View Routes
```bash
rails routes
```

### Database Console
```bash
rails dbconsole
```
---

**Built with ❤Love using Ruby on Rails for Arkus**