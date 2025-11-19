# config/initializers/cors.rb

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  # Development origins
  if Rails.env.development?
    allow do
      origins "http://localhost:5173", "http://127.0.0.1:5173"

      resource "*",
        headers: :any,
        methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
        credentials: true,
        max_age: 600
    end
  end

  # Production origins
  if Rails.env.production?
    allow do
      # Set this via environment variable or update with your actual frontend URL
      origins ENV.fetch("FRONTEND_URL", "https://devhub-frontend.onrender.com")

      resource "*",
        headers: :any,
        methods: [ :get, :post, :put, :patch, :delete, :options, :head ],
        credentials: true,
        max_age: 600
    end
  end
end