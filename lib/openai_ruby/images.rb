module OpenAI
  class Images
    attr_reader :connection

    def initialize(connection)
      @connection = connection
    end

    def generate(params = {})
      connection.post("/v1/images/generations", params.to_json)
    end
  end
end
