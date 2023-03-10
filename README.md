# OpenAI Ruby library

[![Gem Version](https://badge.fury.io/rb/openai_ruby.svg)](https://badge.fury.io/rb/openai_ruby)
[![Build Status](https://travis-ci.org/renny-ren/openai_ruby.svg?branch=main)](https://travis-ci.org/renny-ren/openai_ruby)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/renny-ren/openai_ruby/blob/main/LICENSE)

This is a Ruby wrapper for [OpenAI API](https://openai.com/api/), which provides convenient access to the OpenAI API from applications written in Ruby.

Let's build next-gen apps with OpenAI’s powerful models.

## Installation

Add it to your Gemfile by executing:

```ruby
gem "openai_ruby"
```

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install openai_ruby

## Usage

Before starting, you need to have an API key, if not, create one [here](https://platform.openai.com/account/api-keys)

create a client like this:

```ruby
client = OpenAI::Client.new("your OpenAI key here")
```

### Completion

```ruby
res = client.create_completion(
  model: "text-davinci-003", # The model which will generate the completion
  prompt: "Hello, who are you?",
  max_tokens: 100 # The maximum number of tokens to generate
  temperature: 0.5, # Control randomness
  top_p: 1,
  frequency_penalty: 0,
  presence_penalty: 0,
  stop: "\n"
)
p res.status  # 200
response = JSON.parse(res.body)

p response.dig("choices", 0, "text")  # "I am an AI created by OpenAI."
p response.dig('usage', 'total_tokens')  # 18
```

### Edit

```ruby
res = client.create_edit(
  model: "text-davinci-edit-001",
  input: "What are the date today?",
  instruction: "Fix the grammer."
)
response = JSON.parse(res.body)
p response.dig("choices", 0, "text")  # "What is the date today?\n"
```

### Image

```ruby

```

## Development

After checking out the repo, run `bin/setup` to install dependencies.

You can run `rake spec` to run the tests.

You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/renny-ren/openai_ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/renny-ren/openai_ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Openai::Ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/renny-ren/openai_ruby/blob/main/CODE_OF_CONDUCT.md).
