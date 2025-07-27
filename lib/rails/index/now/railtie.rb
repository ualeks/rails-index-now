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

      end
    end
  end
end
