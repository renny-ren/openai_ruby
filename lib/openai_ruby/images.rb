module OpenAI
  class Images
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def generate(params = {})
      connection.post("/v1/images/generations", params.to_json)
    end

    def edit(params = {})
      connection.post("/v1/images/edits") do |req|
        req.headers.delete("Content-Type")
        req.body = multipart_params(params)
      end
    end

    private

    def multipart_params(params)
      params.each_with_object({}) do |(key, value), body|
        if key.to_s == "image"
          body[:image] = Array(value).map { |image| file_part(image) }
        elsif file_like?(value)
          body[key] = file_part(value)
        elsif value.is_a?(Array)
          body[key] = value
        elsif !value.nil?
          body[key] = value
        end
      end
    end

    def file_part(file)
      return file if file.is_a?(Faraday::Multipart::FilePart)

      if file.respond_to?(:path) && file.path
        Faraday::Multipart::FilePart.new(file.path, content_type_for(file))
      else
        Faraday::Multipart::FilePart.new(file, content_type_for(file), filename_for(file))
      end
    end

    def file_like?(value)
      value.respond_to?(:read) || value.is_a?(Faraday::Multipart::FilePart)
    end

    def content_type_for(file)
      file.respond_to?(:content_type) && file.content_type ? file.content_type : "application/octet-stream"
    end

    def filename_for(file)
      file.respond_to?(:original_filename) && file.original_filename ? file.original_filename : "image.png"
    end
  end
end
