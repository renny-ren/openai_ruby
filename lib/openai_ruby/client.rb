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

    def create_chat_completion(params = {}, &block)
      if params[:stream]
        connection.post("/v1/chat/completions") do |req|
          req.body = params.to_json
          req.options.on_data = Proc.new do |chunk, overall_received_bytes, env|
            block.call(chunk, overall_received_bytes, env)
          end
        end
      else
        connection.post(
          "/v1/chat/completions",
          params.to_json,
          headers
        )
      end
    end

    def create_edit(params = {})
      Faraday.post(
        "#{BASE_URL}/v1/edits",
        params.to_json,
        headers
      )
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
