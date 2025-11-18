# User model with Authlogic authentication
class User < ApplicationRecord
  self.record_timestamps = false

  # Authlogic authentication
  acts_as_authentic do |config|
    config.crypto_provider = ::Authlogic::CryptoProviders::SCrypt
  end

  # Add password confirmation virtual attribute
  attr_accessor :password_confirmation

  # Associations
  has_many :tasks, as: :assignee, dependent: :nullify

  # Validations
  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, confirmation: true, if: :password_required?
  validates :password_confirmation, presence: true, if: :password_required?

  private

  def password_required?
    crypted_password.blank? || password.present?
  end
end
