# frozen_string_literal: true

module OpenAI
  class Client
    BASE_URL = "https://api.openai.com"

    attr_reader :api_key, :options

    def initialize(api_key, options = {})
      @api_key = api_key
      @options = options
    end

    def create_completion(params = {})
      Faraday.post(
        "#{BASE_URL}/v1/completions",
        params.to_json,
        headers
      )
    end

    def create_chat_completion(params = {})
      parser = EventStreamParser::Parser.new

      params.deep_stringify_keys!
      if params["stream"]
        connection.post("/v1/chat/completions") do |req|
          req.body = params.to_json
          req.options.on_data = proc do |chunk, _overall_received_bytes, env|
            if env && env.status != 200
              raise_error = Faraday::Response::RaiseError.new
              raise_error.on_complete(env.merge(body: try_parse_json(chunk)))
            end

            parser.feed(chunk) do |_type, data|
              yield(JSON.parse(data)) if block_given? && data != "[DONE]"
            end
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
      Faraday.new({ url: BASE_URL, headers: headers }.merge(options))
    end

    def headers
      {
        "Content-Type" => "application/json",
        "Authorization" => "Bearer #{api_key}"
      }
    end

    def try_parse_json(maybe_json, default_value = nil)
      JSON.parse(maybe_json)
    rescue JSON::ParserError
      default_value || maybe_json
    end
  end
end
