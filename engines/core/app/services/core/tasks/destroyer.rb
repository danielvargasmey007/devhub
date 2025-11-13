# Service: Handles task deletion with audit trail
module Core
  module Tasks
    class Destroyer
      attr_reader :task, :errors

      def initialize(task)
        @task = task
        @errors = []
      end

      def call
        return false unless valid?

        ActiveRecord::Base.transaction do
          log_activity
          @task.destroy!
        end

        true
      rescue ActiveRecord::RecordInvalid => e
        @errors << e.message
        false
      end

      private

      def valid?
        unless @task.present?
          @errors << "Task must be present"
          return false
        end

        true
      end

      def log_activity
        ::Activity.create!(
          record_type: @task.class.name,
          record_id: @task.id,
          action: "destroyed"
        )
      end
    end
  end
end