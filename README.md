# OpenAI Ruby library

[![Gem Version](https://badge.fury.io/rb/rb-openai.svg)](https://badge.fury.io/rb/rb-openai)

This is a Ruby wrapper for [OpenAI API](https://openai.com/api/), which provides convenient access to the OpenAI API from applications written in Ruby, helps us to build next-gen apps with OpenAI’s powerful models.

## Installation

Add it to your Gemfile by executing:

```ruby
    gem "rb-openai"
```

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install rb-openai

## Usage

```ruby
    client = OpenAI::Client.new("your openai key here")
    client.create_completion(
      model: "text-davinci-003",
      prompt: "What is the date today?",
      max_tokens: 100
    )
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/renny-ren/openai-ruby. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/renny-ren/openai-ruby/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Openai::Ruby project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/renny-ren/openai-ruby/blob/main/CODE_OF_CONDUCT.md).
