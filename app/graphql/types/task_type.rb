module Types
  class TaskType < Types::BaseObject
    description "A task within a project"

    field :id, ID, null: false, description: "Unique identifier for the task"
    field :title, String, null: false, description: "Task title"
    field :description, String, null: true, description: "Task description"
    field :status, Types::TaskStatusEnum, null: false, description: "Current task status"

    field :project, Types::ProjectType, null: false, description: "Project this task belongs to"
    field :assignee, Types::UserType, null: true, description: "User assigned to this task"

    field :assignee_type, String, null: true, description: "Type of assignee (polymorphic)"
    field :assignee_id, ID, null: true, description: "ID of assignee (polymorphic)"

    def project
      object.project
    end

    def assignee
      # Handle polymorphic association - for now we only support User assignees
      object.assignee if object.assignee_type == "User"
    end
  end
end
