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