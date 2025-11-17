module Mutations
  module Tasks
    class DeleteTask < BaseMutation
      description "Delete a task"

      # Input fields
      argument :id, ID, required: true, description: "Task ID"

      # Return fields
      field :success, Boolean, null: false, description: "Whether the deletion was successful"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(id:)
        task = Task.find_by(id: id)

        unless task
          return {
            success: false,
            errors: [ "Task not found with ID: #{id}" ]
          }
        end

        service = Core::Tasks::Destroyer.new(task)

        if service.call
          {
            success: true,
            errors: []
          }
        else
          {
            success: false,
            errors: [ "Failed to delete task" ]
          }
        end
      end
    end
  end
end
