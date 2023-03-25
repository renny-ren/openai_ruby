# OpenAI Ruby library

[![Gem Version](https://badge.fury.io/rb/openai_ruby.svg)](https://badge.fury.io/rb/openai_ruby)
[![GitHub license](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/renny-ren/openai_ruby/blob/main/LICENSE)

This is a Ruby wrapper for [OpenAI API](https://platform.openai.com/docs/api-reference), which provides convenient access to the OpenAI API from applications written in Ruby.

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
https://platform.openai.com/docs/api-reference/completions

```ruby
# params = {
#   model: "text-davinci-003",
#   prompt: "Hello, who are you?",
#   max_tokens: 100,
#   temperature: 0.5,
#   frequency_penalty: 0,
#   presence_penalty: 0,
# }
res = client.create_completion(params)
response = JSON.parse(res.body)

p response.dig("choices", 0, "text")  # "I am an AI created by OpenAI."
p response.dig('usage', 'total_tokens')  # 18
```

### Chat Completion 
https://platform.openai.com/docs/api-reference/chat/create

If you set `stream` param to `true`, a block will be called with the chunk data:

```ruby
# params = {
#   model: "gpt-3.5-turbo",
#   prompt: "Hello",
#   max_tokens: 100,
#   temperature: 1,
#   stream: true,
# }
res = client.create_chat_completion(params) do |chunk, overall_received_bytes, env|
  data = chunk[/data: (.*)\n\n$/, 1]
  p data # {"id":"chatcmpl-6xcOWMQcilJUwJiosi7Rht6Fvuu3D","object":"chat.completion.chunk","created":1679666960,"model":"gpt-3.5-turbo-0301","choices":[{"delta":{"content":"Hello"},"index":0,"finish_reason":null}]}
  if data == "[DONE]"
    # the stream is end
  else
    response = JSON.parse(data)
    p response.dig("choices", 0, "text")  # "Hello"
  end
end
```

### Edit
https://platform.openai.com/docs/api-reference/edits

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
