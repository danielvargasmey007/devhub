module Mutations
  module Projects
    class CreateProject < BaseMutation
      description "Create a new project"

      # Input fields
      argument :name, String, required: true, description: "Project name"
      argument :description, String, required: false, description: "Project description"

      # Return fields
      field :project, Types::ProjectType, null: true, description: "The created project"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(name:, description: nil)
        project_params = { name: name, description: description }.compact
        service = Core::Projects::Creator.new(project_params)

        if service.call
          {
            project: service.project,
            errors: []
          }
        else
          {
            project: nil,
            errors: service.errors
          }
        end
      end
    end
  end
end
