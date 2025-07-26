# frozen_string_literal: true

RSpec.describe Rails::Index::Now do
  let(:test_config) do
    Rails::Index::Now::Configuration.new.tap do |c|
      c.api_key = "test-key"
      c.logger = double("logger", info: nil, error: nil)
    end
  end

  before do
    Rails::Index::Now.reset_configuration!
  end

  after do
    Rails::Index::Now.reset_configuration!
  end

  it "has a version number" do
    expect(Rails::Index::Now::VERSION).not_to be nil
  end

  describe ".configure" do
    it "yields configuration object" do
      Rails::Index::Now.configure do |config|
        expect(config).to be_a(Rails::Index::Now::Configuration)
        config.api_key = "test-key"
      end
      
      expect(Rails::Index::Now.configuration.api_key).to eq("test-key")
    end
  end

  describe ".configuration" do
    it "returns a Configuration instance" do
      expect(Rails::Index::Now.configuration).to be_a(Rails::Index::Now::Configuration)
    end

    it "returns the same instance on multiple calls" do
      config1 = Rails::Index::Now.configuration
      config2 = Rails::Index::Now.configuration
      expect(config1).to eq(config2)
    end
  end

  describe ".reset_configuration!" do
    it "resets the configuration" do
      Rails::Index::Now.configure { |c| c.api_key = "test" }
      old_config = Rails::Index::Now.configuration
      
      Rails::Index::Now.reset_configuration!
      new_config = Rails::Index::Now.configuration
      
      expect(new_config).not_to eq(old_config)
      expect(new_config.api_key).to be_nil
    end
  end

  describe ".submit" do
    it "delegates to Client" do
      allow(Rails::Index::Now).to receive(:configuration).and_return(test_config)
      client_instance = instance_double(Rails::Index::Now::Client)
      allow(Rails::Index::Now::Client).to receive(:new).and_return(client_instance)
      
      expect(client_instance).to receive(:submit).with("https://example.com")
      Rails::Index::Now.submit("https://example.com")
    end
  end

  describe ".submit_async" do
    context "when ActiveJob is not available" do
      it "raises an error" do
        expect { Rails::Index::Now.submit_async(["https://example.com"]) }
          .to raise_error("ActiveJob is not available. Please ensure ActiveJob is loaded before using submit_async.")
      end
    end
  end
end
