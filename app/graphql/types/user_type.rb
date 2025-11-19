module Types
  class UserType < Types::BaseObject
    description "A user in the system"

    field :id, ID, null: false, description: "Unique identifier for the user"
    field :name, String, null: false, description: "User's full name"
    field :email, String, null: false, description: "User's email address"
    field :admin, Boolean, null: false, description: "Whether user has admin privileges"
  end
end
