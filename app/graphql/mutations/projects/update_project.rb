module Mutations
  module Projects
    class UpdateProject < BaseMutation
      description "Update an existing project"

      # Input fields
      argument :id, ID, required: true, description: "Project ID"
      argument :name, String, required: false, description: "Project name"
      argument :description, String, required: false, description: "Project description"

      # Return fields
      field :project, Types::ProjectType, null: true, description: "The updated project"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(id:, **attributes)
        project = Project.find_by(id: id)

        unless project
          return {
            project: nil,
            errors: [ "Project not found with ID: #{id}" ]
          }
        end

        service = Core::Projects::Updater.new(project, attributes)

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
