module Core
  class Engine < ::Rails::Engine
    isolate_namespace Core

    # Explicitly configure autoload paths for Core engine services
    config.autoload_paths += %W[
      #{config.root}/app/services
    ]

    config.generators do |g|
      g.test_framework :test_unit
      g.template_engine :erb
    end
  end
end
