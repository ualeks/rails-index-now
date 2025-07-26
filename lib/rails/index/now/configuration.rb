# frozen_string_literal: true

module Rails
  module Index
    module Now
      class Configuration
        attr_accessor :api_key, :host, :disabled, :logger
        
        def initialize
          @api_key = nil
          @host = nil
          @disabled = false
          @logger = defined?(::Rails) ? ::Rails.logger : Logger.new(STDOUT)
        end
        
        def disabled?
          @disabled
        end
        
        def valid?
          !api_key.nil? && !api_key.empty?
        end
      end
    end
  end
end