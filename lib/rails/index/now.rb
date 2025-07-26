# frozen_string_literal: true

require_relative "now/version"
require_relative "now/configuration"
require_relative "now/client"

module Rails
  module Index
    module Now
      class Error < StandardError; end
      
      class << self
        def configure
          yield(configuration)
        end
        
        def configuration
          @configuration ||= Configuration.new
        end
        
        def reset_configuration!
          @configuration = nil
        end
        
        def submit(urls)
          Client.new.submit(urls)
        end
      end
    end
  end
end
