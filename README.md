# Rails IndexNow

[![Gem Version](https://badge.fury.io/rb/rails-index-now.svg)](https://badge.fury.io/rb/rails-index-now)
[![Build Status](https://github.com/aleksdavtian/rails-index-now/workflows/CI/badge.svg)](https://github.com/aleksdavtian/rails-index-now/actions)

A modern, plug-and-play Rails Engine for seamless integration with Microsoft's IndexNow protocol. Get your content indexed by search engines instantly, with automatic API key verification and zero manual configuration.

## What is IndexNow?

[IndexNow](https://www.indexnow.org/) is a revolutionary protocol developed by Microsoft and adopted by major search engines including Bing, Yandex, and others. It allows websites to instantly notify search engines when content is added, updated, or deleted, dramatically reducing the time between content publication and search engine indexing.

### Why IndexNow Matters

- **Instant Indexing**: Content appears in search results within minutes instead of days or weeks
- **Improved SEO**: Fresh content gets discovered and ranked faster
- **Better User Experience**: Users find your latest content immediately
- **Reduced Server Load**: No more waiting for search engine crawlers to discover changes
- **Free**: The IndexNow protocol is completely free to use

Traditional search engine indexing relies on crawlers periodically visiting your site. With IndexNow, you proactively tell search engines exactly what has changed, when it changed, making the indexing process nearly instantaneous.

### Why This Rails Engine?

- **🚀 Plug-and-Play**: No manual controller or route setup required
- **🔐 Automatic Verification**: The engine automatically serves your API key file at the correct URL
- **⚡ Zero Configuration**: Just add the gem, run the generator, and you're ready
- **🛡️ Production Ready**: Built-in error handling, logging, and environment controls

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

## Quick Setup

### 1. Install the Gem

Add to your Gemfile and run `bundle install`:

```ruby
gem 'rails-index-now'
```

### 2. Generate Configuration

```bash
rails generate index_now:install
```

### 3. Configure Your API Key

Get your free API key from [Bing IndexNow](https://www.bing.com/indexnow/getstarted) and add it to your environment:

```bash
# .env or your environment
INDEXNOW_API_KEY=your_api_key_here
```

**That's it!** The engine automatically:
- ✅ Serves your API key at `/your_api_key_here.txt` (for IndexNow verification)  
- ✅ Handles all routing and controller logic
- ✅ Configures sensible defaults for all environments

### Configuration Options

The generator creates `config/initializers/index_now.rb` with these options:

```ruby
Rails::Index::Now.configure do |config|
  # Required: Your IndexNow API key
  config.api_key = ENV.fetch("INDEXNOW_API_KEY", nil)
  
  # Required: Key file name (automatically set from your API key)
  config.key_file_name = "#{ENV.fetch('INDEXNOW_API_KEY', 'your-api-key')}.txt"
  
  # Optional: Set a specific host for all submissions
  # config.host = "yourdomain.com"
  
  # Optional: Disable IndexNow in specific environments  
  config.disabled = Rails.env.test? || Rails.env.development?
  
  # Optional: Set a custom logger
  # config.logger = Rails.logger
end
```

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

### Background Processing (Optional)

For production applications, use background jobs to avoid blocking web requests. **Note: This requires ActiveJob to be available in your application.**

```ruby
# Submit URLs asynchronously using ActiveJob (requires ActiveJob)
Rails::Index::Now.submit_async("https://yourdomain.com/articles/123")

Rails::Index::Now.submit_async([
  "https://yourdomain.com/articles/123",
  "https://yourdomain.com/articles/124"
])
```

The gem works seamlessly with any ActiveJob backend (Sidekiq, SolidQueue, GoodJob, etc.) when ActiveJob is available.

### Rails Model Integration

The magic happens when you integrate IndexNow with your Rails models. Here's a complete example:

```ruby
class Article < ApplicationRecord
  # Automatically notify search engines when articles are created or updated
  after_commit :submit_to_index_now, on: [:create, :update]
  
  private
  
  def submit_to_index_now
    return unless published? && Rails.env.production?
    
    # The engine handles everything - just submit the URL!
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

**What happens automatically:**
1. 🔥 Your article gets saved 
2. 🚀 `after_commit` triggers IndexNow submission
3. 🎯 Search engines are notified within seconds
4. ✅ Your content appears in search results faster

### Advanced Usage

For more complex scenarios, you can also use the job directly (requires ActiveJob):

```ruby
# Use the provided ActiveJob directly (requires ActiveJob)
Rails::Index::Now::SubmitJob.perform_later([
  "https://yourdomain.com/page1",
  "https://yourdomain.com/page2"
])

# Or perform immediately (not recommended for web requests)
Rails::Index::Now::SubmitJob.perform_now(["https://yourdomain.com/page"])
```

**Note:** If ActiveJob is not available, use the synchronous `submit` method instead.

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

This Rails Engine requires:

- **Rails 5.0+** (for Rails Engine support)
- **Ruby 2.7+**
- **ActiveJob** (optional, only needed for `submit_async` functionality)

The engine automatically integrates with your Rails application:

- **🔄 Automatic Routing**: No need to manually add routes - the engine handles it
- **🎛️ Controller Integration**: Built-in controller serves API key verification file
- **⚡ ActiveJob**: Optional - enables `submit_async` method with any backend (Sidekiq, SolidQueue, etc.)
- **📝 Smart Logging**: Uses Rails.logger with helpful [IndexNow] prefixes
- **🌍 Environment Awareness**: Easy to disable in development/test environments
- **🛠️ Rails Generators**: One-command setup with `rails generate index_now:install`

## Performance Considerations

- **Asynchronous by Design**: The `submit_async` method queues jobs to avoid blocking web requests (when ActiveJob is available)
- **Lightweight**: Zero runtime dependencies - uses only Ruby standard library
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
