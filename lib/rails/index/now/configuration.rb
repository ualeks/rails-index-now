# frozen_string_literal: true

module Rails
  module Index
    module Now
      class Configuration
        attr_accessor :api_key, :host, :disabled, :logger, :key_file_name

        def initialize
          @api_key = nil
          @host = nil
          @disabled = false
          @logger = default_logger
          @key_file_name = nil
        end

        def disabled?
          @disabled
        end

        def valid?
          !api_key.nil? && !api_key.empty?
        end

        def engine_valid?
          valid? && !key_file_name.nil? && !key_file_name.empty?
        end

        private

        def default_logger
          if defined?(::Rails) && ::Rails.respond_to?(:logger) && ::Rails.logger
            ::Rails.logger
          else
            require "logger"
            Logger.new($stdout)
          end
        end
      end
    end
  end
end
