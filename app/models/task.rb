# Task model with polymorphic assignee and status tracking
class Task < ApplicationRecord
  self.record_timestamps = false

  # Associations
  belongs_to :project
  belongs_to :assignee, polymorphic: true, optional: true

  # Enums
  enum :status, {
    pending: "pending",
    in_progress: "in_progress",
    completed: "completed",
    archived: "archived"
  }, default: :pending, validate: true

  # Validations
  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 5000 }, allow_blank: true

  # Scopes
  scope :completed, -> { where(status: "completed") }
  scope :assigned_to, ->(user) { user ? where(assignee: user) : none }
end
