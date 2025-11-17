module Mutations
  module Tasks
    class UpdateTask < BaseMutation
      description "Update a task (non-status attributes)"

      # Input fields
      argument :id, ID, required: true, description: "Task ID"
      argument :title, String, required: false, description: "Task title"
      argument :description, String, required: false, description: "Task description"
      argument :assignee_id, ID, required: false, description: "Assignee ID"
      argument :assignee_type, String, required: false, description: "Assignee type (e.g., 'User')"

      # Return fields
      field :task, Types::TaskType, null: true, description: "The updated task"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(id:, **attributes)
        task = Task.find_by(id: id)

        unless task
          return {
            task: nil,
            errors: [ "Task not found with ID: #{id}" ]
          }
        end

        # Remove status from attributes - use updateTaskStatus for status changes
        attributes.delete(:status)

        service = Core::Tasks::Updater.new(task, attributes)

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
