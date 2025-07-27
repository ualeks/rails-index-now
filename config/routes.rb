# frozen_string_literal: true

Rails::Index::Now::Engine.routes.draw do
  # Only match files that look like API keys (alphanumeric + hyphens/underscores, ending in .txt)
  get "/:key_file_name", to: "verification#index_now_key", 
      constraints: { key_file_name: /[a-zA-Z0-9_-]+\.txt/ }
end
