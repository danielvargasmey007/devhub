# User model with secure password authentication
class User < ApplicationRecord
  self.record_timestamps = false

  has_secure_password

  # Associations
  has_many :tasks, as: :assignee, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, length: { minimum: 6 }, if: -> { password.present? }
end
