# Service: Handles project updates with audit trail
module Core
  module Projects
    class Updater
      attr_reader :project, :errors

      def initialize(project, project_params)
        @project = project
        @project_params = project_params
        @errors = []
      end

      def call
        if @project.update(@project_params)
          log_activity
          true
        else
          @errors = @project.errors.full_messages
          false
        end
      end

      private

      def log_activity
        ::Activity.create!(
          record_type: @project.class.name,
          record_id: @project.id,
          action: "updated"
        )
      end
    end
  end
end