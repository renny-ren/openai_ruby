# frozen_string_literal: true

require_relative "lib/openai_ruby/version"

Gem::Specification.new do |spec|
  spec.name = "openai_ruby"
  spec.version = OpenAI::VERSION
  spec.authors = ["Renny Ren"]
  spec.email = ["rennyrjh@gmail.com"]

  spec.summary = "A Ruby wrapper for OpenAI API"
  spec.homepage = "https://github.com/renny-ren/openai_ruby"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/renny-ren/openai_ruby"
  spec.metadata["changelog_uri"] = "https://github.com/renny-ren/openai_ruby/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject do |f|
      (f == __FILE__) || f.match(%r{\A(?:(?:bin|test|spec|features)/|\.(?:git|travis|circleci)|appveyor)})
    end
  end

  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "event_stream_parser", "~> 1.0"
  spec.add_dependency "faraday", "~> 2.7"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
