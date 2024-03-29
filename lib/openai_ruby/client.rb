# frozen_string_literal: true

module OpenAI
  class Client
    BASE_URL = "https://api.openai.com"

    attr_reader :api_key

    def initialize(api_key)
      @api_key = api_key
    end

    def create_completion(params = {})
      Faraday.post(
        "#{BASE_URL}/v1/completions",
        params.to_json,
        headers
      )
    end

    def create_chat_completion(params = {})
      params.deep_stringify_keys!
      if params["stream"]
        connection.post("/v1/chat/completions") do |req|
          req.body = params.to_json
          req.options.on_data = proc do |chunk, overall_received_bytes, env|
            yield(chunk, overall_received_bytes, env) if block_given?
          end
        end
      else
        connection.post("/v1/chat/completions", params.to_json)
      end
    end

    def create_edit(params = {})
      Faraday.post(
        "#{BASE_URL}/v1/edits",
        params.to_json,
        headers
      )
    end

    def images
      @images ||= OpenAI::Images.new(connection)
    end

    private

    def connection
      Faraday.new(url: BASE_URL, headers: headers)
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{api_key}"
      }
    end
  end
end
