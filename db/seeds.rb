# DevHub Seed Data - Week 1
# Creates demo users, project, and tasks for development

puts "Seeding DevHub database..."

# Clean up existing data (for idempotency)
Activity.destroy_all
Task.destroy_all
Project.destroy_all
User.destroy_all

# Create Users
puts "Creating users..."
alice = User.create!(
  name: "Alice Johnson",
  email: "alice@devhub.com",
  password: "password123",
  password_confirmation: "password123"
)

bob = User.create!(
  name: "Bob Smith",
  email: "bob@devhub.com",
  password: "password123",
  password_confirmation: "password123"
)

charlie = User.create!(
  name: "Charlie Davis",
  email: "charlie@devhub.com",
  password: "password123",
  password_confirmation: "password123"
)

puts "Created #{User.count} users"

# Create Project
puts "Creating project..."
project = Project.create!(
  name: "DevHub MVP",
  description: "Initial MVP for DevHub - Developer Task & Project Management Application"
)

puts "Created project: #{project.name}"

# Create Tasks
puts "Creating tasks..."
task1 = Task.create!(
  title: "Setup database schema",
  description: "Design and implement PostgreSQL database schema for users, projects, and tasks",
  status: :completed,
  project: project,
  assignee: alice
)

task2 = Task.create!(
  title: "Implement user authentication",
  description: "Add user authentication with Authlogic gem and secure password handling",
  status: :in_progress,
  project: project,
  assignee: bob
)

task3 = Task.create!(
  title: "Build admin dashboard",
  description: "Create read-only admin dashboard showing project and task statistics",
  status: :in_progress,
  project: project,
  assignee: alice
)

task4 = Task.create!(
  title: "Add GraphQL API",
  description: "Implement GraphQL API for querying projects and tasks",
  status: :pending,
  project: project,
  assignee: charlie
)

task5 = Task.create!(
  title: "Setup background job processing",
  description: "Configure Sidekiq for handling asynchronous tasks and email notifications",
  status: :pending,
  project: project
)

puts "Created #{Task.count} tasks"

# Create some activities using the service
puts "Creating activity logs..."
updater = TaskStatusUpdater.new(task1, :completed)
updater.call

puts "Created #{Activity.count} activities"

puts "\n✓ Seeding complete!"
puts "  Users: #{User.count}"
puts "  Projects: #{Project.count}"
puts "  Tasks: #{Task.count}"
puts "  Activities: #{Activity.count}"
