# frozen_string_literal: true

RSpec.describe Rails::Index::Now::Configuration do
  let(:config) { described_class.new }

  describe "initialization" do
    it "sets default values" do
      expect(config.api_key).to be_nil
      expect(config.host).to be_nil
      expect(config.disabled).to be false
      expect(config.logger).not_to be_nil
    end

    it "sets Rails.logger when Rails is defined" do
      rails_logger = double("logger")
      stub_const("Rails", double(logger: rails_logger))
      
      new_config = described_class.new
      expect(new_config.logger).to eq(rails_logger)
    end
  end

  describe "#disabled?" do
    it "returns false by default" do
      expect(config.disabled?).to be false
    end

    it "returns true when disabled is set to true" do
      config.disabled = true
      expect(config.disabled?).to be true
    end
  end

  describe "#valid?" do
    it "returns false when api_key is nil" do
      config.api_key = nil
      expect(config.valid?).to be false
    end

    it "returns false when api_key is empty string" do
      config.api_key = ""
      expect(config.valid?).to be false
    end

    it "returns true when api_key is set" do
      config.api_key = "test-key"
      expect(config.valid?).to be true
    end
  end

  describe "attribute accessors" do
    it "allows setting and getting api_key" do
      config.api_key = "my-api-key"
      expect(config.api_key).to eq("my-api-key")
    end

    it "allows setting and getting host" do
      config.host = "example.com"
      expect(config.host).to eq("example.com")
    end

    it "allows setting and getting disabled" do
      config.disabled = true
      expect(config.disabled).to be true
    end

    it "allows setting and getting logger" do
      custom_logger = double("logger")
      config.logger = custom_logger
      expect(config.logger).to eq(custom_logger)
    end
  end
end