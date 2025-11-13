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
        @task = @project.tasks.build(@task_params)

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
