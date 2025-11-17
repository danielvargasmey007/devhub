module Types
  class QueryType < Types::BaseObject
    description "The query root of the GraphQL schema"

    # Field naming convention:
    # Use `field_name` instead of `fieldName` for consistency with Ruby conventions

    # ===== PROJECT QUERIES =====

    field :projects, [ Types::ProjectType ], null: false,
      description: "Get all projects"

    def projects
      Project.includes(:tasks).all
    end

    field :project, Types::ProjectType, null: true,
      description: "Get a single project by ID" do
      argument :id, ID, required: true, description: "Project ID"
    end

    def project(id:)
      Project.includes(:tasks).find_by(id: id)
    end

    # ===== TASK QUERIES =====

    field :tasks, [ Types::TaskType ], null: false,
      description: "Get all tasks, optionally filtered by project" do
      argument :project_id, ID, required: false, description: "Filter tasks by project ID"
    end

    def tasks(project_id: nil)
      scope = Task.includes(:project, :assignee)
      scope = scope.where(project_id: project_id) if project_id
      scope.all
    end

    field :task, Types::TaskType, null: true,
      description: "Get a single task by ID" do
      argument :id, ID, required: true, description: "Task ID"
    end

    def task(id:)
      Task.includes(:project, :assignee).find_by(id: id)
    end
  end
end
