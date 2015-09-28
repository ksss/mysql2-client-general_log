Mysql2::Client::GeneralLogs
===

A monkey patch for Mysql2.
Stock all general logs.

```ruby
#! /usr/bin/env ruby

require "mysql2/client/general_logs"

client = Mysql2::Client.new(config)
client.query("SELECT * FROM users LIMIT 1")

p client.general_logs #=> [
  #<struct Mysql2::Client::GeneralLogs::Log
    sql="SELECT * FROM users LIMIT 1",
    backtrace=["script.rb:6:in `<main>'"]>
]
```

## Examples

### sinatra

```ruby
helpers do
  def db
    Thread.current[:db] ||= Mysql2::Client.new(config)
  end
end

get '/' do
  # ...
end

after do
  puts db.query_logs.map(&:sql)
  puts "path:#{request.path}\tsql:#{db.query_logs.length}"
  db.query_logs.clear
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mysql2-client-general_logs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mysql2-client-general_logs

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/mysql2-client-general_logs. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
