Admin::Engine.routes.draw do
  root to: "dashboard#index"
  get "dashboard", to: "dashboard#index"
end
