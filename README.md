## takwimu - GC, Rack and Rails Statsd Reporter

A fork of [trashed](https://github.com/basecamp/trashed) and [barnes](https://github.com/heroku/barnes). There is also some ActiveSupport notification based on [vitals](https://github.com/jondot/vitals)

We had some of this functionality baked into our app in various forms and we decided to bring it all together into one gem.

The key features are:
1. Railtie which autoloads a scheduled stats pushed to Stats
    1. Ruby GC Stats
    2. Phusion Passenger (if installed)
    3. Puma (if installed) 
2. ActionController and ActiveRecord per request stats pushed to StatsD

>
> **Note:** If you are using Phusion Passenger you must run Passenger as a user with sudo capabilities since Passenger does not provide a facility to directly query statistics.
> 
> To do this add the user in the servers configuration: 
> 
> For Apache add PassengerUser _username_ to your server or virtual host configuration. 
>
> For Nginx add passenger_user _username_; to your http or server blocks.

This is a work in progress and we will keep adding more features but welcome any pull requests.   

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

