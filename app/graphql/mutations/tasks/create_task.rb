module Mutations
  module Tasks
    class CreateTask < BaseMutation
      description "Create a new task"

      # Input fields
      argument :project_id, ID, required: true, description: "Project ID"
      argument :title, String, required: true, description: "Task title"
      argument :description, String, required: false, description: "Task description"
      argument :status, Types::TaskStatusEnum, required: false, description: "Task status (default: pending)"
      argument :assignee_id, ID, required: false, description: "Assignee ID"
      argument :assignee_type, String, required: false, description: "Assignee type (e.g., 'User')"

      # Return fields
      field :task, Types::TaskType, null: true, description: "The created task"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(project_id:, title:, **attributes)
        project = Project.find_by(id: project_id)

        unless project
          return {
            task: nil,
            errors: [ "Project not found with ID: #{project_id}" ]
          }
        end

        task_params = {
          title: title,
          description: attributes[:description],
          status: attributes[:status] || :pending,
          assignee_id: attributes[:assignee_id],
          assignee_type: attributes[:assignee_type]
        }.compact

        service = Core::Tasks::Creator.new(project, task_params)

        if service.call
          {
            task: service.task,
            errors: []
          }
        else
          {
            task: nil,
            errors: service.errors
          }
        end
      end
    end
  end
end
