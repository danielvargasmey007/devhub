module Mutations
  module Projects
    class DeleteProject < BaseMutation
      description "Delete a project"

      # Input fields
      argument :id, ID, required: true, description: "Project ID"

      # Return fields
      field :success, Boolean, null: false, description: "Whether the deletion was successful"
      field :errors, [ String ], null: false, description: "Validation errors, if any"

      def resolve(id:)
        project = Project.find_by(id: id)

        unless project
          return {
            success: false,
            errors: [ "Project not found with ID: #{id}" ]
          }
        end

        service = Core::Projects::Destroyer.new(project)

        if service.call
          {
            success: true,
            errors: []
          }
        else
          {
            success: false,
            errors: [ "Failed to delete project" ]
          }
        end
      end
    end
  end
end
