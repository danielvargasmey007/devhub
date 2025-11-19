require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Devhub
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.0

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Autoload custom directories for modular architecture
    config.autoload_paths += %W[
      #{config.root}/app/services
      #{config.root}/app/types
      #{config.root}/app/queries
      #{config.root}/app/mutations
    ]

    config.eager_load_paths += %W[
      #{config.root}/app/services
      #{config.root}/app/types
      #{config.root}/app/queries
      #{config.root}/app/mutations
    ]

    # Configure ActiveJob adapter based on environment
    # For Free Tier: Use inline to avoid memory issues with Sidekiq
    # For paid tiers: Set ACTIVE_JOB_ADAPTER=sidekiq
    config.active_job.queue_adapter = ENV.fetch("ACTIVE_JOB_ADAPTER", "inline").to_sym

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
