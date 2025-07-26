# Rails IndexNow

[![Gem Version](https://badge.fury.io/rb/rails-index-now.svg)](https://badge.fury.io/rb/rails-index-now)
[![Build Status](https://github.com/aleksdavtian/rails-index-now/workflows/CI/badge.svg)](https://github.com/aleksdavtian/rails-index-now/actions)

A modern, lightweight Rails gem for seamless integration with Microsoft's IndexNow protocol. Get your content indexed by search engines instantly, without waiting for crawlers.

## What is IndexNow?

[IndexNow](https://www.indexnow.org/) is a revolutionary protocol developed by Microsoft and adopted by major search engines including Bing, Yandex, and others. It allows websites to instantly notify search engines when content is added, updated, or deleted, dramatically reducing the time between content publication and search engine indexing.

### Why IndexNow Matters

- **Instant Indexing**: Content appears in search results within minutes instead of days or weeks
- **Improved SEO**: Fresh content gets discovered and ranked faster
- **Better User Experience**: Users find your latest content immediately
- **Reduced Server Load**: No more waiting for search engine crawlers to discover changes
- **Free**: The IndexNow protocol is completely free to use

Traditional search engine indexing relies on crawlers periodically visiting your site. With IndexNow, you proactively tell search engines exactly what has changed, when it changed, making the indexing process nearly instantaneous.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'rails-index-now'
```

And then execute:

```bash
bundle install
```

Or install it yourself as:

```bash
gem install rails-index-now
```

## Configuration

Generate the initializer file:

```bash
rails generate index_now:install
```

This creates `config/initializers/index_now.rb`. Configure your IndexNow settings:

```ruby
Rails::Index::Now.configure do |config|
  # Required: Your IndexNow API key
  # Get one free at https://www.indexnow.org/
  config.api_key = ENV['INDEXNOW_API_KEY']
  
  # Optional: Set a specific host for all submissions
  # If not set, the gem will extract the host from submitted URLs
  config.host = "yourdomain.com"
  
  # Optional: Disable IndexNow in specific environments
  # Recommended for test and development environments
  config.disabled = Rails.env.test? || Rails.env.development?
  
  # Optional: Set a custom logger
  # Defaults to Rails.logger
  config.logger = Rails.logger
end
```

### Getting Your IndexNow API Key

1. Visit [IndexNow.org](https://www.indexnow.org/)
2. Generate a free API key
3. Add the key to your environment variables or Rails credentials

## Usage

### Basic Usage

Submit URLs for immediate indexing:

```ruby
# Submit a single URL
Rails::Index::Now.submit("https://yourdomain.com/articles/123")

# Submit multiple URLs
Rails::Index::Now.submit([
  "https://yourdomain.com/articles/123",
  "https://yourdomain.com/articles/124"
])
```

### Background Processing (Recommended)

For production applications, use background jobs to avoid blocking web requests:

```ruby
# Submit URLs asynchronously using ActiveJob
Rails::Index::Now.submit_async("https://yourdomain.com/articles/123")

Rails::Index::Now.submit_async([
  "https://yourdomain.com/articles/123",
  "https://yourdomain.com/articles/124"
])
```

The gem works seamlessly with any ActiveJob backend (Sidekiq, SolidQueue, GoodJob, etc.).

### Real-World Rails Integration

Here's how to integrate IndexNow with your Rails models for automatic indexing:

```ruby
class Article < ApplicationRecord
  # Submit to IndexNow after creating or updating articles
  after_commit :submit_to_index_now, on: [:create, :update]
  
  # Also submit when articles are published
  after_commit :submit_to_index_now, if: :saved_change_to_published_at?
  
  private
  
  def submit_to_index_now
    return unless published? && Rails.env.production?
    
    # Submit asynchronously to avoid blocking the web request
    Rails::Index::Now.submit_async(article_url)
  end
  
  def article_url
    Rails.application.routes.url_helpers.article_url(
      self, 
      host: Rails.application.config.action_mailer.default_url_options[:host]
    )
  end
end
```

### Advanced Usage

For more complex scenarios, you can also use the job directly:

```ruby
# Use the provided ActiveJob directly
Rails::Index::Now::SubmitJob.perform_later([
  "https://yourdomain.com/page1",
  "https://yourdomain.com/page2"
])

# Or perform immediately (not recommended for web requests)
Rails::Index::Now::SubmitJob.perform_now(["https://yourdomain.com/page"])
```

### Error Handling

The gem includes comprehensive error handling and logging:

```ruby
# All operations are logged to Rails.logger by default
Rails::Index::Now.submit("https://yourdomain.com/page")
# => [IndexNow] Successfully submitted 1 URLs to IndexNow

# Failed submissions are also logged
Rails::Index::Now.submit("invalid-url")
# => [IndexNow] IndexNow API returned 400: Bad Request
```

## Framework Compatibility

This gem is designed specifically for Rails applications and requires:

- **Rails 6.0+** (for ActiveJob support)
- **Ruby 2.7+**

The gem automatically integrates with your existing Rails infrastructure:

- **ActiveJob**: Works with any ActiveJob backend (Sidekiq, SolidQueue, etc.)
- **Logging**: Uses Rails.logger by default
- **Environment Awareness**: Easy to disable in development/test environments
- **Rails Generators**: Includes installation generator for easy setup

## Performance Considerations

- **Asynchronous by Design**: The `submit_async` method queues jobs to avoid blocking web requests
- **Lightweight**: Zero external dependencies beyond Rails
- **Efficient**: Batches multiple URLs in single API calls when possible
- **Fault Tolerant**: Gracefully handles network failures and API errors

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/aleksdavtian/rails-index-now.

## Author & Credit

This gem was created by **Aleks**. It is proudly used in production at **[DigitalReleaseDates.com](https://digitalreleasedates.com)**, the best place to track when movies and TV shows are available to stream.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/rails-index-now. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/rails-index-now/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Rails::Index::Now project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/rails-index-now/blob/master/CODE_OF_CONDUCT.md).
