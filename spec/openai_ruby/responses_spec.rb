# frozen_string_literal: true

RSpec.describe OpenAI::Client, "#create_response" do
  let(:client) { described_class.new("test-api-key") }

  it "posts non-streaming requests to the Responses endpoint" do
    connection = instance_double(Faraday::Connection)
    allow(client).to receive(:connection).and_return(connection)
    expect(connection).to receive(:post) do |path, body|
      expect(path).to eq("/v1/responses")
      expect(JSON.parse(body)).to include("model" => "gpt-test", "store" => false)
    end

    client.create_response(model: "gpt-test", input: "Hello", store: false)
  end

  it "accepts frozen parameters without modifying them" do
    input = [{ role: "user", content: "Hello" }.freeze].freeze
    params = { model: "gpt-test", input: input, stream: false }.freeze
    connection = instance_double(Faraday::Connection)
    allow(client).to receive(:connection).and_return(connection)
    expect(connection).to receive(:post) do |_path, body|
      expect(JSON.parse(body).fetch("input")).to eq([{ "role" => "user", "content" => "Hello" }])
    end

    client.create_response(params)

    expect(params[:input]).to equal(input)
    expect(params).to be_frozen
  end

  it "uses the configured proxy for Responses requests" do
    proxy = { uri: "http://127.0.0.1:8228" }
    proxied_client = described_class.new("test-api-key", proxy: proxy)
    connection = instance_double(Faraday::Connection)
    expect(Faraday).to receive(:new) do |options, &_block|
      expect(options[:proxy]).to eq(proxy)
      connection
    end
    expect(connection).to receive(:post).with("/v1/responses", kind_of(String))

    proxied_client.create_response(model: "gpt-test", input: "Hello")
  end

  it "yields parsed Responses streaming events" do
    events = [
      { type: "response.output_text.delta", delta: "Hello" },
      { type: "response.completed", response: { id: "resp_123" } },
    ]
    chunks = events.map { |event| "data: #{event.to_json}\n\n" }
    allow(client).to receive(:connection).and_return(streaming_connection(status: 200, chunks: chunks))
    received = []

    response = client.create_response(model: "gpt-test", input: "Hello", stream: true) do |event|
      received << event
    end

    expect(response.status).to eq(200)
    expect(received).to eq(events.map { |event| JSON.parse(event.to_json) })
  end

  it "collects a complete streaming error body" do
    response_body = { error: { message: "Invalid response request" } }.to_json
    chunks = [response_body.byteslice(0, 12), response_body.byteslice(12..)]
    allow(client).to receive(:connection).and_return(streaming_connection(status: 400, chunks: chunks))

    expect do
      client.create_response(model: "gpt-test", input: "Hello", stream: true)
    end.to raise_error(Faraday::BadRequestError) { |error| expect(error.response_body).to eq(JSON.parse(response_body)) }
  end

  def streaming_connection(status:, chunks:)
    instance_double(Faraday::Connection).tap do |streaming_connection|
      allow(streaming_connection).to receive(:post) do |path, &configure_request|
        options = Faraday::RequestOptions.new
        request = Struct.new(:body, :options).new(nil, options)
        configure_request.call(request)
        env = Faraday::Env.from(
          method: :post,
          request_body: request.body,
          url: URI("https://api.openai.com#{path}"),
          request: request.options,
          request_headers: {},
          status: status,
          response_headers: {},
          response_body: nil,
          reason_phrase: status == 200 ? "OK" : "Bad Request"
        )
        total_bytes = 0
        chunks.each do |chunk|
          total_bytes += chunk.bytesize
          request.options.on_data.call(chunk, total_bytes, env)
        end
        Faraday::Response.new(env)
      end
    end
  end
end
