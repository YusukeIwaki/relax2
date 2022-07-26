# Relax2

Relax2 is a quick and dirty HTTP API client factory for Ruby.

```ruby
## petstore.rb
require 'relax2'

base_url 'https://petstore.swagger.io/v2'

interceptor :json_request
interceptor :print_response
```

Then enjoy your API calls.

```
% ruby petstore.rb GET /pet/2
{"id":2,"name":"doggie","photoUrls":[],"tags":[],"status":"available"}
```

```
$ echo '{"id": 2, "name": "NEW DOG", "status": "unavailable"}' | ruby petstore.rb PUT /pet
{"id":2,"name":"NEW DOG","photoUrls":[],"tags":[],"status":"unavailable"}
```

If you want to create more detailed client, use the modular style with `Relax2::Base`.

```ruby
require 'relax2/base'

class ExampleApi < Relax2::Base
  base_url 'http://example.com/api/v1'

  interceptor -> (request, perform_request) do
    puts request.path
    puts request.body
    response = perform_request.call(request)
    puts response.status
    puts response.body
    response
  end
end

# Request manually
request = Relax2::Request.from(args: 'GET /hogehoge q=xx USER-Agent: Hoge/1.23'.split(' '))
response = ExampleApi.call(request)

# or, simply work with CLI args :)
ExampleApi.run
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'relax2'
```

and then `bundle install`

## References

### Examples

* Example of relax2 for [Android Management API](https://developers.google.com/android/management): https://github.com/YusukeIwaki/relax2-androidmanagement-api

### Other langs

* rakuda[https://github.com/YusukeIwaki/rakuda]: Dart implementation. Good for distributing in-house API client tool.
* [@zatsu/core](https://github.com/YusukeIwaki/zatsu-core): Node.js implementation. Useful for distribution with npx.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/YusukeIwaki/relax2.
