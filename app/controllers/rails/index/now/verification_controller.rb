# frozen_string_literal: true

module Rails
  module Index
    module Now
      class VerificationController < ActionController::Base
        # Skip CSRF protection for this simple text response
        skip_before_action :verify_authenticity_token, only: [:index_now_key]

        def index_now_key
          config = Rails::Index::Now.configuration
          requested_file = params[:key_file_name]

          unless config.engine_valid?
            error_details = []
            error_details << "api_key missing" if config.api_key.nil? || config.api_key.empty?
            error_details << "key_file_name missing" if config.key_file_name.nil? || config.key_file_name.empty?
            
            error_message = "IndexNow configuration invalid: #{error_details.join(', ')}"
            Rails.logger.error "[IndexNow] #{error_message}"
            render plain: error_message, status: :internal_server_error
            return
          end

          # Verify the requested file matches our configured key file
          unless requested_file == config.key_file_name
            head :not_found
            return
          end

          render plain: config.api_key, content_type: "text/plain"
        end
      end
    end
  end
end
