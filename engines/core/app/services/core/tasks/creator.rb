# Service: Handles task creation with audit trail
module Core
  module Tasks
    class Creator
      attr_reader :task, :errors

      def initialize(project, task_params)
        @project = project
        @task_params = task_params
        @task = nil
        @errors = []
      end

      def call
        # Handle assignee assignment (polymorphic association)
        assignee = nil
        if @task_params[:assignee_id].present?
          assignee_type = @task_params.delete(:assignee_type) || 'User'
          assignee_id = @task_params.delete(:assignee_id)

          assignee = assignee_type.constantize.find_by(id: assignee_id)
          unless assignee
            @errors << "#{assignee_type} not found with ID: #{assignee_id}"
            return false
          end
        else
          # Remove assignee keys if not present
          @task_params.delete(:assignee_id)
          @task_params.delete(:assignee_type)
        end

        @task = @project.tasks.build(@task_params)
        @task.assignee = assignee if assignee

        if @task.save
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
          action: "created"
        )
      end
    end
  end
end
