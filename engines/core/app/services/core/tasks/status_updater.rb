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

        old_status = task.status
        update_status
        enqueue_activity_log(old_status)
        true
      rescue ActiveRecord::RecordInvalid, StandardError => e
        handle_error(e)
        false
      end

      private

      def update_status
        ActiveRecord::Base.transaction do
          task.update!(status: new_status)
        end
      end

      def enqueue_activity_log(old_status)
        # Enqueue background job to log activity asynchronously
        # This happens AFTER the transaction commits successfully
        ActivityLoggerJob.perform_later(task.id, old_status, new_status)
      end

      def handle_error(error)
        error_message = error.message
        Rails.logger.error("StatusUpdater failed: #{error_message}")
        @errors << error_message
      end

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
    end
  end
end
