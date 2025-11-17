module Types
  class ProjectType < Types::BaseObject
    description "A project containing tasks"

    field :id, ID, null: false, description: "Unique identifier for the project"
    field :name, String, null: false, description: "Project name"
    field :description, String, null: true, description: "Project description"

    field :tasks, [ Types::TaskType ], null: false, description: "All tasks in this project"

    def tasks
      object.tasks
    end
  end
end
