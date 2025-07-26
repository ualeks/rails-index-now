# frozen_string_literal: true

# IndexNow Configuration
# See https://github.com/your-username/rails-index-now for full documentation

Rails::Index::Now.configure do |config|
  # Required: Your IndexNow API key
  # You can get one from https://www.bing.com/indexnow/getstarted
  config.api_key = ENV.fetch("INDEXNOW_API_KEY", nil)

  # Required: Key file name for IndexNow verification
  # This should be "YOUR_API_KEY.txt" (replace YOUR_API_KEY with your actual key)
  # The gem will automatically serve this file at /YOUR_API_KEY.txt
  config.key_file_name = "#{ENV.fetch("INDEXNOW_API_KEY", "your-api-key")}.txt"

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
