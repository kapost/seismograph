# Seismograph

A helper library for writing metrics and events to (http://datadoghq.com)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'seismograph'
```

If not using bundler, be sure to require the gem:

```ruby
require 'seismograph'
```

## Usage

Configure your statsd server:

```ruby
Seismograph.config do |config|
  config.app_name    = 'cabbagepult'  # optional
  config.env         = 'staging'      # optional, defaults to `RAILS_ENV` or `RACK_ENV`
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

### Counting:

Counting is useful for tracking simple quantities or events.  It accepts a numeric value (default
is 1) and an optional block.  In addition to counting, this method will also track success or
failure (via incrementing) depending on whether an error is raised.

```ruby
sensor.count('signup', 2)

sensor.count('signup') do
  User.create!(attributes)
end
```

### Benchmarking:

Benchmarking is useful for tracking how long an operation takes.  In addition to tracking the
timing, this method will also track success or failure (via incrementing) depending on whether an
error is raised.

```ruby
def create
  sensor.benchmark('signup') do
    # Timing will be written for the account.signup metric
    User.create!(params)
  end
end
```

### Timing:

Timing is useful for tracking how long an operation takes, when that operation
has already been run. For example, in the subscriber to an
`ActiveSupport::Instrumentation` event. Expects the duration argument to be in
ms (which the ActiveSupport event.duration already is).

```ruby
class ActiveJobSubscriber < ActiveSupport::Subscriber

  attach_to :active_job

  def perform(event)
    job = event.payload[:job]

    sensor.timing "perform", event.duration, sample_rate: 0.5, tags: [job.name, job.queue_name]
  end

  def sensor
    @sensor ||= Seismograph::Sensor.new("active_job")
  end

end
```

### Incrementing/Decrementing:

Simple incrementing and decrementing can be performed on a stat.  Both methods accept a numeric
value (default is 1).

```ruby
sensor.increment('memberships')
sensor.decrement('memberships', 2)
```

### Logging events:

Logging can be used for tracking critical events.  Valid log methods are `info`, `warning`,
`error`, and `success`.

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
