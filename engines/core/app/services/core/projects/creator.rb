# Service: Handles project creation with audit trail
module Core
  module Projects
    class Creator
      attr_reader :project, :errors

      def initialize(project_params)
        @project_params = project_params
        @project = nil
        @errors = []
      end

      def call
        @project = ::Project.new(@project_params)

        if @project.save
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
          action: "created"
        )
      end
    end
  end
end
