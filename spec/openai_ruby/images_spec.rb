# frozen_string_literal: true

require "stringio"

RSpec.describe OpenAI::Images, "#generate" do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:images) { described_class.new(connection) }

  it "posts JSON to the image generations endpoint" do
    expect(connection).to receive(:post).with(
      "/v1/images/generations",
      { model: "gpt-image-2", prompt: "cat" }.to_json
    )

    images.generate(model: "gpt-image-2", prompt: "cat")
  end
end

RSpec.describe OpenAI::Images, "#edit" do
  let(:connection) { instance_double(Faraday::Connection) }
  let(:images) { described_class.new(connection) }

  it "posts multipart image arrays to the image edits endpoint" do
    requests = []
    allow(connection).to receive(:post) do |path, &block|
      req = Struct.new(:headers, :body).new({ "Content-Type" => "application/json" }, nil)
      block.call(req)
      requests << [path, req]
    end

    file1 = StringIO.new("image-one")
    file2 = StringIO.new("image-two")

    images.edit(
      model: "gpt-image-2",
      prompt: "make variations",
      image: [file1, file2]
    )

    path, req = requests.first
    expect(path).to eq("/v1/images/edits")
    expect(req.headers).not_to have_key("Content-Type")
    expect(req.body[:model]).to eq("gpt-image-2")
    expect(req.body[:prompt]).to eq("make variations")
    expect(req.body[:image].length).to eq(2)
    expect(req.body[:image]).to all(be_a(Faraday::Multipart::FilePart))
  end
end
