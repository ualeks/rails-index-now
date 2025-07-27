# frozen_string_literal: true

# IndexNow Configuration
# See https://github.com/your-username/rails-index-now for full documentation

Rails::Index::Now.configure do |config|
  # The gem automatically reads INDEXNOW_API_KEY from ENV
  # You can override it here if needed:
  # config.api_key = "your-custom-key"
  
  # The gem automatically sets key_file_name to "#{ENV['INDEXNOW_API_KEY']}.txt"
  # You can override it here if needed:
  # config.key_file_name = "custom-filename.txt"

  # Optional: Set a specific host for all submissions
  # If not set, the gem will extract the host from the submitted URLs
  # config.host = "example.com"

  # Optional: Disable IndexNow in specific environments
  # Recommended for test and development environments
  config.disabled = Rails.env.test? || Rails.env.development?

  # Optional: Set a custom logger
  # Defaults to Rails.logger if available, otherwise STDOUT
  # config.logger = Rails.logger
end

# IMPORTANT: Add this to your config/routes.rb file:
#
# Option A (recommended - serves key at /your_api_key.txt):
# Rails.application.routes.draw do
#   mount Rails::Index::Now::Engine, at: "/"
# end
#
# Option B (if you have routing conflicts):
# Rails.application.routes.draw do
#   mount Rails::Index::Now::Engine, at: "/indexnow"
# end
