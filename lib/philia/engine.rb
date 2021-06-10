module Philia
  class Engine < ::Rails::Engine
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
