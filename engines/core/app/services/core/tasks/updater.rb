# Service: Handles task updates (non-status changes) with audit trail
module Core
  module Tasks
    class Updater
      attr_reader :task, :errors

      def initialize(task, task_params)
        @task = task
        @task_params = task_params
        @errors = []
      end

      def call
        # Handle assignee assignment (polymorphic association)
        if @task_params.key?(:assignee_id)
          assignee_id = @task_params.delete(:assignee_id)
          assignee_type = @task_params.delete(:assignee_type) || 'User'

          if assignee_id.present?
            @task.assignee = assignee_type.constantize.find_by(id: assignee_id)
            unless @task.assignee
              @errors << "#{assignee_type} not found with ID: #{assignee_id}"
              return false
            end
          else
            # Empty string means unassign
            @task.assignee = nil
          end
        end

        if @task.update(@task_params)
          log_activity
          true
        else
          @errors = @task.errors.full_messages
          false
        end
      end

      private

      def log_activity
        ::Activity.create!(
          record_type: @task.class.name,
          record_id: @task.id,
          action: "updated"
        )
      end
    end
  end
end
