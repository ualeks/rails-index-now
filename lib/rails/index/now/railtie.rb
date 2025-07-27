# frozen_string_literal: true

require "rails/engine"

module Rails
  module Index
    module Now
      class Engine < ::Rails::Engine
        isolate_namespace Rails::Index::Now

        generators do
          require "generators/index_now/install_generator"
        end

        initializer "rails_index_now.add_routes" do |app|
          app.routes.prepend do
            config = Rails::Index::Now.configuration
            if config.engine_valid?
              get "/#{config.key_file_name}",
                  to: "rails/index/now/verification#index_now_key"
            end
          end
        end
      end
    end
  end
end
