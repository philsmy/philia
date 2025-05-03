# engine.rb
module Philia
  class Engine < ::Rails::Engine
    isolate_namespace Philia # Keep this line as removing it didn't help

    # Ensure that Devise is loaded properly
    initializer "philia.before_load", before: :load_config_initializers do
      require "devise"
    end

    # Be cautious with adding to autoload_paths to avoid conflicts
    # Only add necessary directories and do not duplicate paths already handled by Rails
    # config.autoload_paths += Dir["#{config.root}/app/controllers/philia"]

    config.after_initialize do
      ActiveSupport.on_load(:active_record) do
        include Philia::Base
      end
      ActiveSupport.on_load(:action_controller_base) do
        include Philia::Control
      end
    end
  end
end
