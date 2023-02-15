# frozen_string_literal: true

module OpenAI
  class Client
    BASE_URL = "https://api.openai.com".freeze

    attr_reader :api_key

    def initialize(api_key)
      @api_key = api_key
    end

    def create_completion(params)
      Faraday.post(
        "#{BASE_URL}/v1/completions",
        params.to_json,
        headers
      )
    end

    private

    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{api_key}",
      }
    end
  end
end
