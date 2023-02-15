# frozen_string_literal: true

require "faraday"
require "openai_ruby/client"
require "openai_ruby/version"

module OpenAI
  class Error < StandardError
  end
end
