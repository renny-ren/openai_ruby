# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
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

  it "collects a complete streaming error body before raising" do
    response_body = {
      error: {
        message: "Invalid image URL. The URL must be a valid HTTP or HTTPS URL.",
        type: "invalid_request_error",
        param: "messages[1].content[1].image_url.url",
        code: "invalid_value"
      }
    }.to_json
    chunks = [response_body.byteslice(0, 20), response_body.byteslice(20..)]
    allow(client).to receive(:connection).and_return(
      streaming_connection(status: 400, chunks: chunks, headers: { "x-request-id" => "req_complete_error" })
    )

    matcher = raise_error(Faraday::BadRequestError) do |error|
      expect(error.response_body).to eq(JSON.parse(response_body))
      expect(error.response_headers["x-request-id"]).to eq("req_complete_error")
    end
    expect do
      client.create_chat_completion(model: "gpt-test", messages: [], stream: true)
    end.to matcher
  end

  it "preserves successful streaming callbacks" do
    event = { choices: [{ delta: { content: "Hello" } }] }
    chunks = ["data: #{event.to_json}\n\n", "data: [DONE]\n\n"]
    allow(client).to receive(:connection).and_return(streaming_connection(status: 200, chunks: chunks))
    received = []

    response = client.create_chat_completion(model: "gpt-test", messages: [], stream: true) do |data|
      received << data
    end

    expect(response.status).to eq(200)
    expect(received).to eq([JSON.parse(event.to_json)])
  end

  def streaming_connection(status:, chunks:, headers: {})
    instance_double(Faraday::Connection).tap do |streaming_connection|
      allow(streaming_connection).to receive(:post) do |path, &configure_request|
        options = Faraday::RequestOptions.new
        request = Struct.new(:body, :options).new(nil, options)
        configure_request.call(request)
        env = streaming_env(path, request, status, headers)
        emit_chunks(request, env, chunks)
        Faraday::Response.new(env)
      end
    end
  end

  def streaming_env(path, request, status, headers)
    Faraday::Env.from(
      method: :post, request_body: request.body, url: URI("https://api.openai.com#{path}"),
      request: request.options, request_headers: { "Authorization" => "Bearer test-api-key" },
      status: status, response_headers: headers, response_body: nil,
      reason_phrase: status == 200 ? "OK" : "Bad Request"
    )
  end

  def emit_chunks(request, env, chunks)
    total_bytes = 0
    chunks.each do |chunk|
      total_bytes += chunk.bytesize
      request.options.on_data.call(chunk, total_bytes, env)
    end
  end
end
# rubocop:enable Metrics/BlockLength

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
