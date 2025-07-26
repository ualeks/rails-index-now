# frozen_string_literal: true

RSpec.describe Rails::Index::Now::Client do
  let(:config) do
    Rails::Index::Now::Configuration.new.tap do |c|
      c.api_key = "test-api-key"
      c.logger = double("logger", info: nil, error: nil)
    end
  end
  let(:client) { described_class.new(config) }

  before do
    WebMock.disable_net_connect!
  end

  after do
    WebMock.allow_net_connect!
  end

  describe "#submit" do
    context "when configuration is disabled" do
      before { config.disabled = true }

      it "returns without making request" do
        expect(client.submit("https://example.com/page")).to be_nil
      end

      it "does not make HTTP request" do
        client.submit("https://example.com/page")
        expect(WebMock).not_to have_requested(:post, "https://api.indexnow.org/indexnow")
      end
    end

    context "when configuration is invalid" do
      before { config.api_key = nil }

      it "logs error and returns false" do
        expect(config.logger).to receive(:error).with("[IndexNow] IndexNow configuration is invalid. API key is required.")
        expect(client.submit("https://example.com/page")).to be false
      end
    end

    context "with valid configuration" do
      let(:test_urls) { ["https://example.com/page1", "https://example.com/page2"] }

      describe "payload construction" do
        before do
          stub_request(:post, "https://api.indexnow.org/indexnow")
            .to_return(status: 200)
        end

        it "constructs correct payload for single URL" do
          client.submit("https://example.com/page")
          
          expect(WebMock).to have_requested(:post, "https://api.indexnow.org/indexnow")
            .with(body: {
              host: "example.com",
              key: "test-api-key",
              urlList: ["https://example.com/page"]
            }.to_json)
        end

        it "constructs correct payload for multiple URLs" do
          client.submit(test_urls)
          
          expect(WebMock).to have_requested(:post, "https://api.indexnow.org/indexnow")
            .with(body: {
              host: "example.com",
              key: "test-api-key",
              urlList: test_urls
            }.to_json)
        end

        it "uses configured host when provided" do
          config.host = "custom-host.com"
          client.submit("https://example.com/page")
          
          expect(WebMock).to have_requested(:post, "https://api.indexnow.org/indexnow")
            .with(body: hash_including(host: "custom-host.com"))
        end

        it "extracts host from URL when not configured" do
          client.submit("https://different.com/page")
          
          expect(WebMock).to have_requested(:post, "https://api.indexnow.org/indexnow")
            .with(body: hash_including(host: "different.com"))
        end

        it "sends correct headers" do
          client.submit("https://example.com/page")
          
          expect(WebMock).to have_requested(:post, "https://api.indexnow.org/indexnow")
            .with(headers: { "Content-Type" => "application/json" })
        end
      end

      describe "HTTP success scenarios" do
        it "returns true and logs success on 200 response" do
          stub_request(:post, "https://api.indexnow.org/indexnow")
            .to_return(status: 200)

          expect(config.logger).to receive(:info).with("[IndexNow] Successfully submitted 1 URLs to IndexNow")
          expect(client.submit("https://example.com/page")).to be true
        end

        it "handles multiple URLs correctly" do
          stub_request(:post, "https://api.indexnow.org/indexnow")
            .to_return(status: 200)

          expect(config.logger).to receive(:info).with("[IndexNow] Successfully submitted 2 URLs to IndexNow")
          expect(client.submit(test_urls)).to be true
        end
      end

      describe "HTTP failure scenarios" do
        it "returns false and logs error on 400 response" do
          stub_request(:post, "https://api.indexnow.org/indexnow")
            .to_return(status: 400, body: "Bad Request")

          expect(config.logger).to receive(:error).with("[IndexNow] IndexNow API returned 400: Bad Request")
          expect(client.submit("https://example.com/page")).to be false
        end

        it "returns false and logs error on 422 response" do
          stub_request(:post, "https://api.indexnow.org/indexnow")
            .to_return(status: 422, body: "Unprocessable Entity")

          expect(config.logger).to receive(:error).with("[IndexNow] IndexNow API returned 422: Unprocessable Entity")
          expect(client.submit("https://example.com/page")).to be false
        end

        it "returns false and logs error on 500 response" do
          stub_request(:post, "https://api.indexnow.org/indexnow")
            .to_return(status: 500, body: "Internal Server Error")

          expect(config.logger).to receive(:error).with("[IndexNow] IndexNow API returned 500: Internal Server Error")
          expect(client.submit("https://example.com/page")).to be false
        end
      end

      describe "timeout scenarios" do
        it "handles read timeout and returns false" do
          stub_request(:post, "https://api.indexnow.org/indexnow")
            .to_raise(Net::ReadTimeout)

          expect(config.logger).to receive(:error).with(/\[IndexNow\] Request timeout when submitting to IndexNow:.*Net::ReadTimeout/)
          expect(client.submit("https://example.com/page")).to be false
        end

        it "handles open timeout and returns false" do
          stub_request(:post, "https://api.indexnow.org/indexnow")
            .to_raise(Net::OpenTimeout)

          expect(config.logger).to receive(:error).with(/\[IndexNow\] Request timeout when submitting to IndexNow:.*/)
          expect(client.submit("https://example.com/page")).to be false
        end
      end

      describe "error handling" do
        it "handles invalid URLs gracefully" do
          expect(config.logger).to receive(:error).with(/Invalid URL provided.*Error:/)
          expect(client.submit("http://[invalid")).to be_nil
        end
        
        it "handles URLs with no host gracefully" do
          expect(client.submit("not-a-valid-url")).to be_nil
        end

        it "handles unexpected errors" do
          stub_request(:post, "https://api.indexnow.org/indexnow")
            .to_raise(StandardError.new("Something went wrong"))

          expect(config.logger).to receive(:error).with("[IndexNow] Unexpected error when submitting to IndexNow: Something went wrong")
          expect(client.submit("https://example.com/page")).to be false
        end

        it "returns early for empty URL list" do
          expect(client.submit([])).to be_nil
          expect(WebMock).not_to have_requested(:post, "https://api.indexnow.org/indexnow")
        end
      end
    end
  end
end