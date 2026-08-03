# frozen_string_literal: true

RSpec.describe OpenAI::Client, "#create_chat_completion" do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:client) { described_class.new("test-api-key") }
  let(:required_fields) { %w[enhanced_answer sample_answer].freeze }
  let(:schema) { { type: "object", required: required_fields }.freeze }
  let(:params) do
    {
      model: "gpt-test",
      response_format: { type: "json_schema", json_schema: { schema: schema }.freeze }.freeze,
      stream: false
    }.freeze
  end

  it "accepts frozen nested parameters without modifying the caller's objects" do
    allow(client).to receive(:connection).and_return(connection)
    expect(connection).to receive(:post) do |path, body|
      expect(path).to eq("/v1/chat/completions")
      expect(JSON.parse(body).dig("response_format", "json_schema", "schema", "required"))
        .to eq(required_fields)
    end

    client.create_chat_completion(params)

    expect(params.keys).to include(:model, :response_format, :stream)
    expect(params.dig(:response_format, :json_schema, :schema)).to equal(schema)
    expect(schema[:required]).to equal(required_fields)
    expect(required_fields).to be_frozen
  end
end

RSpec.describe OpenAI::Client, "#create_speech" do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:client) { described_class.new("test-api-key") }

  it "does not modify frozen nested parameters" do
    audio_options = { voice: "alloy", format: "mp3" }.freeze
    params = { model: "gpt-test", audio: audio_options }.freeze

    allow(client).to receive(:connection).and_return(connection)
    expect(connection).to receive(:post) do |path, body|
      expect(path).to eq("/v1/audio/speech")
      expect(JSON.parse(body).fetch("audio")).to eq("voice" => "alloy", "format" => "mp3")
    end

    client.create_speech(params)

    expect(params[:audio]).to equal(audio_options)
    expect(params.keys).to include(:model, :audio)
  end
end

RSpec.describe OpenAI::Client, "#create_realtime_call" do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:proxy) { { uri: "http://127.0.0.1:8228" } }
  let(:client) { described_class.new("test-api-key", proxy: proxy) }

  it "posts through the configured connection" do
    expect(Faraday).to receive(:new) do |options, &_block|
      expect(options[:proxy]).to eq(proxy)
      connection
    end

    expect(connection).to receive(:post).with("/v1/realtime/calls") do |&block|
      req = Struct.new(:headers, :body).new({}, nil)
      block.call(req)

      expect(req.headers["Authorization"]).to eq("Bearer test-api-key")
      expect(req.headers["Content-Type"]).to eq("application/sdp")
      expect(req.body).to eq("sdp-offer")
    end

    client.create_realtime_call(sdp_offer: "sdp-offer")
  end
end
