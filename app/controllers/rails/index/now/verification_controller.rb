# frozen_string_literal: true

module Rails
  module Index
    module Now
      class VerificationController < ActionController::Base
        # Skip CSRF protection for this simple text response
        skip_before_action :verify_authenticity_token, only: [:index_now_key]

        def index_now_key
          config = Rails::Index::Now.configuration

          unless config.engine_valid?
            render plain: "IndexNow configuration invalid", status: :internal_server_error
            return
          end

          render plain: config.api_key, content_type: "text/plain"
        end
      end
    end
  end
end
