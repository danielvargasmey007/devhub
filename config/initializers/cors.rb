# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # Allow requests from React frontend during development
    origins "http://localhost:5173", "http://127.0.0.1:5173"

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
      credentials: true,
      max_age: 600
  end

  # In production, you would specify your production frontend URL:
  # allow do
  #   origins "https://your-production-frontend.com"
  #
  #   resource "*",
  #     headers: :any,
  #     methods: [:get, :post, :put, :patch, :delete, :options, :head],
  #     credentials: true
  # end
end