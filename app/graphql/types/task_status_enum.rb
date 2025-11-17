module Types
  class TaskStatusEnum < Types::BaseEnum
    description "Available task statuses"

    value "PENDING", "Task is pending", value: "pending"
    value "IN_PROGRESS", "Task is in progress", value: "in_progress"
    value "COMPLETED", "Task is completed", value: "completed"
    value "ARCHIVED", "Task is archived", value: "archived"
  end
end
