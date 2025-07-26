# frozen_string_literal: true

require_relative "lib/rails/index/now/version"

Gem::Specification.new do |spec|
  spec.name = "rails-index-now"
  spec.version = Rails::Index::Now::VERSION
  spec.authors = ["Aleks Ulanov"]
  spec.email = ["sashachilly.z@gmail.com"]

  # --- REVISED SECTION ---
  spec.summary = "A simple Ruby client for the IndexNow protocol, with easy integration for Rails."
  spec.description = "Instantly notify search engines like Bing and DuckDuckGo of content changes in your Rails app. " \
                     "This gem provides a simple client and Active Job integration for the IndexNow API."
  spec.homepage = "https://github.com/ualeks/rails-index-now"
  # --- END REVISED SECTION ---

  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.1.0"

  # --- REVISED METADATA ---
  # This should be set to the official RubyGems server
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  # --- END REVISED METADATA ---

  spec.metadata["homepage_uri"] = "https://github.com/ualeks/rails-index-now"
  spec.metadata["source_code_uri"] = "https://github.com/ualeks/rails-index-now"
  spec.metadata["changelog_uri"] = "https://github.com/ualeks/rails-index-now/blob/main/CHANGELOG.md"
  spec.metadata["rubygems_mfa_required"] = "true"

  # ... (the rest of the file is perfect as is)

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) || f.start_with?(*%w[bin/ test/ spec/ features/ .git .github .vscode Gemfile])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # No runtime dependencies - gem uses only Ruby standard library
end
