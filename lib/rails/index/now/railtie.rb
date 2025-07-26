# frozen_string_literal: true

require "rails/railtie"

module Rails
  module Index
    module Now
      class Railtie < ::Rails::Railtie
        generators do
          require_relative "generators/install_generator"
        end
      end
    end
  end
end
