# Seismograph

A helper library for writing metrics and events to (http://datadoghq.com)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'seismograph'
```

## Usage

Configure your statsd server:

```ruby
require 'seismograph'

Seismograph.config do |config|
  config.app_name    = 'cabbagepult'
  config.statsd_host = ENV.fetch('STATSD_HOST')
  config.statsd_port = ENV.fetch('STATSD_PORT')
end
```

After creating a sensor that designates a metric namespace, you can write values to it:

```ruby
require 'seismograph'

def sensor
  @_sensor ||= Seismograph::Sensor.new('account')
end

def create
  users_to_create = [user1, user_2]

  sensor.count('signup', users_to_create.size) do
    # If an error is raised, the 'account.signup.failure' metric will be incremented instead
    User.create!(users_to_create)
  end
end
```

#### Benchmarking:

```ruby
def create
  sensor.benchmark('signup') do
    # Timing will be written for the account.signup metric
    User.create!(params)
  end
end
```

#### Logging events:

```ruby
task :deploy do
  begin
    deploy!
    Seismograph::Log.info('App Deployed')
  rescue StandardError => e
    Seismograph::Log.error('Deployment failed!', description: e.message)
  end

  # "warning" and "success" are the remaining type alert type possibilities
end


```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
