# Project model representing development projects
class Project < ApplicationRecord
  self.record_timestamps = false

  # Associations
  has_many :tasks, dependent: :destroy

  # Validations
  validates :name, presence: true
end
