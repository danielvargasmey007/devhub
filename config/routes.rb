Rails.application.routes.draw do
  # Mount Admin engine at /admin
  mount Admin::Engine, at: "/admin"

  # Mount Core engine at /core (uncomment when ready to use)
  # mount Core::Engine, at: "/core"

  # RESTful resources
  resources :projects do
    resources :tasks
  end

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root path
  root "projects#index"
end
