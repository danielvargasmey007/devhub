class ActivityLoggerJob < ApplicationJob
  queue_as :default

  # Log activity asynchronously when a task status changes
  def perform(task_id, old_status, new_status)
    logger = Rails.logger
    task = Task.find_by(id: task_id)

    unless task
      logger.warn("ActivityLoggerJob: Task not found with ID: #{task_id}")
      return
    end

    action = "status_changed_from_#{old_status}_to_#{new_status}"

    Activity.create!(
      record: task,
      action: action
    )

    logger.info("ActivityLoggerJob: Logged activity for Task ##{task_id}: #{action}")
  rescue StandardError => e
    logger.error("ActivityLoggerJob failed for Task ##{task_id}: #{e.message}")
    raise # Re-raise to trigger Sidekiq retry mechanism
  end
end
