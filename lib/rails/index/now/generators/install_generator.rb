# frozen_string_literal: true

require 'rails/generators/base'

module Rails
  module Index
    module Now
      module Generators
        class InstallGenerator < ::Rails::Generators::Base
          source_root File.expand_path('templates', __dir__)
          
          desc "Creates an IndexNow initializer file"
          
          def create_initializer_file
            template "index_now.rb", "config/initializers/index_now.rb"
          end
        end
      end
    end
  end
end