# Puma configuration for production deployment

# Allow threads to be set via environment
# Free Tier: Use 2-3 threads max to conserve memory
threads_count = ENV.fetch("RAILS_MAX_THREADS", 2)
threads threads_count, threads_count

# Bind to PORT environment variable (Render provides this)
port ENV.fetch("PORT", 3000)

# Specify the environment
environment ENV.fetch("RAILS_ENV", "development")

# Workers for production
# Free Tier: Use 0 workers (single process mode) to save memory
# Paid Tier: Set WEB_CONCURRENCY=2 or higher
workers ENV.fetch("WEB_CONCURRENCY", 0).to_i

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