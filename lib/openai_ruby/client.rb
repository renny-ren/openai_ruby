# frozen_string_literal: true

module OpenAI
  class Client
    DEFAULT_BASE_URI = "https://api.openai.com"

    attr_reader :api_key, :options, :base_uri

    def initialize(api_key, options = {})
      @api_key = api_key
      @options = options
      @base_uri = options[:base_uri] || DEFAULT_BASE_URI
    end

    def create_completion(params = {})
      Faraday.post("#{base_uri}/v1/completions", params.to_json, headers)
    end

    def create_chat_completion(params = {}, &block)
      return connection.post("/v1/chat/completions", params.to_json) unless streaming?(params)

      create_streaming_request("/v1/chat/completions", params, &block)
    end

    def create_response(params = {}, &block)
      return connection.post("/v1/responses", params.to_json) unless streaming?(params)

      create_streaming_request("/v1/responses", params, &block)
    end

    def create_edit(params = {})
      Faraday.post("#{base_uri}/v1/edits", params.to_json, headers)
    end

    def create_speech(params = {})
      connection.post("/v1/audio/speech", params.to_json)
    end

    def images
      @images ||= OpenAI::Images.new(connection)
    end

    def create_realtime_call(sdp_offer:, session: nil)
      if session
        boundary, body = build_multipart_body(sdp_offer, session)
        connection.post("/v1/realtime/calls") do |req|
          req.headers["Authorization"] = "Bearer #{api_key}"
          req.headers["Content-Type"] = "multipart/form-data; boundary=#{boundary}"
          req.body = body
        end
      else
        connection.post("/v1/realtime/calls") do |req|
          req.headers["Content-Type"] = "application/sdp"
          req.headers["Authorization"] = "Bearer #{api_key}"
          req.body = sdp_offer
        end
      end
    end

    private

    def connection
      Faraday.new({ url: base_uri, headers: headers }.merge(options.except(:base_uri))) do |faraday|
        faraday.request :multipart
      end
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

    def streaming?(params)
      params[:stream] || params["stream"]
    end

    def create_streaming_request(path, params, &block)
      parser = EventStreamParser::Parser.new
      error_body = +""
      response = connection.post(path) do |req|
        req.body = params.to_json
        req.options.on_data = proc do |chunk, _overall_received_bytes, env|
          handle_streaming_chunk(parser, error_body, chunk, env, &block)
        end
      end

      raise_streaming_response_error(response, error_body) unless response.status == 200
      response
    end

    def handle_streaming_chunk(parser, error_body, chunk, env)
      return error_body << chunk unless env&.status == 200

      parser.feed(chunk) do |_type, data|
        yield(JSON.parse(data)) if block_given? && data != "[DONE]"
      end
    end

    def raise_streaming_response_error(response, body)
      error_env = response.env.merge(body: try_parse_json(body))
      Faraday::Response::RaiseError.new.on_complete(error_env)
    end

    def build_multipart_body(sdp_offer, session)
      boundary = "----RubyFormBoundary#{SecureRandom.hex(16)}"
      parts = [
        ["--#{boundary}", 'Content-Disposition: form-data; name="sdp"', "Content-Type: application/sdp", "", sdp_offer],
        ["--#{boundary}", 'Content-Disposition: form-data; name="session"', "Content-Type: application/json", "",
         session.to_json],
        ["--#{boundary}--"]
      ]

      [boundary, parts.flatten.join("\r\n")]
    end
  end
end
