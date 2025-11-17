module Types
  class MutationType < Types::BaseObject
    description "The mutation root of the GraphQL schema"

    # ===== PROJECT MUTATIONS =====
    field :create_project, mutation: Mutations::Projects::CreateProject,
      description: "Create a new project"

    field :update_project, mutation: Mutations::Projects::UpdateProject,
      description: "Update an existing project"

    field :delete_project, mutation: Mutations::Projects::DeleteProject,
      description: "Delete a project"

    # ===== TASK MUTATIONS =====
    field :create_task, mutation: Mutations::Tasks::CreateTask,
      description: "Create a new task"

    field :update_task, mutation: Mutations::Tasks::UpdateTask,
      description: "Update a task (non-status attributes)"

    field :update_task_status, mutation: Mutations::Tasks::UpdateTaskStatus,
      description: "Update a task's status (triggers async activity logging)"

    field :delete_task, mutation: Mutations::Tasks::DeleteTask,
      description: "Delete a task"
  end
end
