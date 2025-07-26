# frozen_string_literal: true

require_relative "now/version"
require_relative "now/configuration"
require_relative "now/client"
require_relative "now/submit_job"
require_relative "now/railtie" if defined?(Rails::Railtie)

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
        
        def submit_async(urls)
          SubmitJob.perform_later(urls)
        end
      end
    end
  end
end
