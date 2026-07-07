# frozen_string_literal: true

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
