# Service: Handles task status changes and creates audit trail
# Encapsulates business logic for status transitions
module Core
  module Tasks
    class StatusUpdater
      attr_reader :task, :new_status, :errors

      def initialize(task, new_status)
        @task = task
        @new_status = new_status
        @errors = []
      end

      def call
        return false unless valid?

        ActiveRecord::Base.transaction do
          old_status = task.status
          task.update!(status: new_status)
          log_activity(old_status)
        end

        true
      rescue ActiveRecord::RecordInvalid => e
        @errors << e.message
        false
      end

      private

      def valid?
        unless task.present?
          @errors << "Task must be present"
          return false
        end

        unless ::Task.statuses.key?(new_status.to_s)
          @errors << "Invalid status: #{new_status}"
          return false
        end

        true
      end

      def log_activity(old_status)
        ::Activity.create!(
          record_type: task.class.name,
          record_id: task.id,
          action: "status_changed_from_#{old_status}_to_#{new_status}"
        )
      end
    end
  end
end