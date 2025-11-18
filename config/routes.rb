Rails.application.routes.draw do
  # Authentication routes
  resources :users, only: [ :new, :create ]
  resources :user_sessions, only: [ :new, :create, :destroy ]

  # Named authentication routes for convenience
  get "signup", to: "users#new", as: "signup"
  get "login", to: "user_sessions#new", as: "login"
  delete "logout", to: "user_sessions#destroy", as: "logout"

  # Current user endpoint for future React integration
  get "me", to: "users#me", as: "current_user"

  # Mount Admin engine at /admin
  mount Admin::Engine, at: "/admin"

  # GraphQL API endpoint
  post "/graphql", to: "graphql#execute"

  # GraphiQL IDE (development only)
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path - redirect to GraphiQL in development, Admin in production
  root to: redirect { |params, request|
    if Rails.env.development?
      "/graphiql"
    else
      "/admin"
    end
  }
end
