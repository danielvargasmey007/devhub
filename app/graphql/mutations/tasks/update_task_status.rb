module Mutations
  module Tasks
    class UpdateTaskStatus < BaseMutation
      description "Update a task's status (triggers async activity logging)"

      # Input fields
      argument :id, ID, required: true, description: "Task ID"
      argument :status, Types::TaskStatusEnum, required: true, description: "New task status"

      # Return fields
      field :task, Types::TaskType, null: true, description: "The updated task"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(id:, status:)
        task = Task.find_by(id: id)

        unless task
          return {
            task: nil,
            errors: [ "Task not found with ID: #{id}" ]
          }
        end

        # Use the existing Core::Tasks::StatusUpdater service
        # This will automatically trigger ActivityLoggerJob asynchronously
        service = Core::Tasks::StatusUpdater.new(task, status)

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
