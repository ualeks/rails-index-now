# frozen_string_literal: true

require "net/http"
require "json"
require "uri"

module Rails
  module Index
    module Now
      class Client
        INDEXNOW_API_URL = "https://api.indexnow.org/indexnow"

        def initialize(config = Rails::Index::Now.configuration)
          @config = config
        end

        def submit(urls)
          return if @config.disabled?

          unless @config.valid?
            log_error("IndexNow configuration is invalid. API key is required.")
            return false
          end

          url_list = Array(urls)
          return if url_list.empty?

          host = determine_host(url_list.first)
          return nil if host.nil?

          payload = build_payload(host, url_list)

          make_request(payload)
        end

        private

        def determine_host(sample_url)
          return @config.host if @config.host

          begin
            URI.parse(sample_url).host
          rescue URI::InvalidURIError => e
            log_error("Invalid URL provided: #{sample_url}. Error: #{e.message}")
            nil
          end
        end

        def build_payload(host, url_list)
          {
            host: host,
            key: @config.api_key,
            urlList: url_list
          }
        end

        def make_request(payload)
          response = send_http_request(payload)
          process_response(response, payload[:urlList].size)
        rescue Net::ReadTimeout, Net::OpenTimeout => e
          log_error("Request timeout when submitting to IndexNow: #{e.message}")
          false
        rescue StandardError => e
          log_error("Unexpected error when submitting to IndexNow: #{e.message}")
          false
        end

        def send_http_request(payload)
          uri = URI(INDEXNOW_API_URL)
          http = create_http_client(uri)
          request = create_post_request(uri, payload)
          http.request(request)
        end

        def create_http_client(uri)
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http
        end

        def create_post_request(uri, payload)
          request = Net::HTTP::Post.new(uri)
          request["Content-Type"] = "application/json"
          request.body = payload.to_json
          request
        end

        def process_response(response, url_count)
          if ["200", "202"].include?(response.code)
            log_info("Successfully submitted #{url_count} URLs to IndexNow (#{response.code})")
            true
          else
            log_error("IndexNow API returned #{response.code}: #{response.body}")
            false
          end
        end

        def log_info(message)
          @config.logger&.info("[IndexNow] #{message}")
        end

        def log_error(message)
          @config.logger&.error("[IndexNow] #{message}")
        end
      end
    end
  end
end
