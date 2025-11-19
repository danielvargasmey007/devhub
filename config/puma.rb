# Puma configuration for production deployment

# Allow threads to be set via environment
threads_count = ENV.fetch("RAILS_MAX_THREADS", 3)
threads threads_count, threads_count

# Bind to PORT environment variable (Render provides this)
port ENV.fetch("PORT", 3000)

# Specify the environment
environment ENV.fetch("RAILS_ENV", "development")

# Workers for production (Render free tier: use 1, paid: scale up)
workers ENV.fetch("WEB_CONCURRENCY", 2)

# Preload application for better memory usage with workers
preload_app!

# Allow puma to be restarted by `bin/rails restart` command
plugin :tmp_restart

# Run Solid Queue supervisor inside Puma if enabled
plugin :solid_queue if ENV["SOLID_QUEUE_IN_PUMA"]

# PID file location
pidfile ENV["PIDFILE"] if ENV["PIDFILE"]

# Configure worker boot
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end