# Service: Handles project deletion with audit trail
module Core
  module Projects
    class Destroyer
      attr_reader :project, :errors

      def initialize(project)
        @project = project
        @errors = []
      end

      def call
        return false unless valid?

        ActiveRecord::Base.transaction do
          log_activity
          @project.destroy!
        end

        true
      rescue ActiveRecord::RecordInvalid => e
        @errors << e.message
        false
      end

      private

      def valid?
        unless @project.present?
          @errors << "Project must be present"
          return false
        end

        true
      end

      def log_activity
        ::Activity.create!(
          record_type: @project.class.name,
          record_id: @project.id,
          action: "destroyed"
        )
      end
    end
  end
end
