## takwimu - GC, Rack and Rails Statsd Reporter

A fork of [trashed](https://github.com/basecamp/trashed) and [barnes](https://github.com/heroku/barnes)

## Setup

### Rails 5

On Rails 5 (and Rails 3 and 4), add this to your Gemfile:

```
gem "takwimu"
```

Then run:

```
$ bundle install
```

### Non-Rails

Add the gem to the Gemfile

```
gem "takwimu"
```

Then run:

```
$ bundle install
```

In your application:


```ruby
require 'takwimu'
```

Then you'll need to start the client with default values:

```ruby
Takwimu.start
```

