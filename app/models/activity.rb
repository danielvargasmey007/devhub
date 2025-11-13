# Activity model for tracking record changes (audit trail)
class Activity < ApplicationRecord
  # Associations
  belongs_to :record, polymorphic: true, optional: true

  # Validations
  validates :action, presence: true, length: { maximum: 50 }

  # Scopes
  scope :recent, -> { order(created_at: :desc).limit(20) }
  scope :for_record, ->(record) {
    where(record_type: record.class.name, record_id: record.id)
  }

  # Define timestamp attributes (only created_at exists, no updated_at)
  def self.timestamp_attributes_for_create
    [ "created_at" ]
  end

  def self.timestamp_attributes_for_update
    []
  end
end