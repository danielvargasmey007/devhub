module Types
  class ActivityType < Types::BaseObject
    description "An activity log entry for a record"

    field :id, ID, null: false, description: "Unique identifier for the activity"
    field :action, String, null: false, description: "Action performed"
    field :created_at, GraphQL::Types::ISO8601DateTime, null: false, description: "When the activity occurred"

    field :record_type, String, null: false, description: "Type of record (polymorphic)"
    field :record_id, ID, null: false, description: "ID of record (polymorphic)"
  end
end
