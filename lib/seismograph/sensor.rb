require 'seismograph/gateway'
require 'seismograph/parameterize'

module Seismograph
  class Sensor
    include Parameterize

    attr_reader :namespace

    def initialize(namespace)
      @namespace = namespace
    end

    def count(description, amount, params = {}, &block)
      track(description, amount, params, &block)
    end

    def increment(description, params = {})
      Gateway.increment(stat(description), gateway_params(params))
    end

    def decrement(description, params = {})
      Gateway.decrement(stat(description), gateway_params(params))
    end

    # Record the time (in ms) when the code has already been executed. Useful for
    # ActiveSupport::Instrumentation event.duration (which is already in ms)
    def timing(description, duration, params = {})
      Gateway.timing(stat(description), duration, gateway_params(params))
    end

    def benchmark(description, params = {}, &block)
      with_success_and_failure(description, params) do
        Gateway.time(stat(description), gateway_params(params), &block)
      end
    end

    def gauge(description, value, params = {})
      Gateway.gauge(stat(description), value, gateway_params(params))
    end

    private

    def track(description, amount, params = {})
      with_success_and_failure(description, params) do
        result = yield if block_given?
        Gateway.histogram(stat(description), amount, gateway_params(params))
        result
      end
    end

    def with_success_and_failure(description, params)
      result = yield
      increment("#{description}.success", gateway_params(params))
      result
    rescue StandardError => e
      increment("#{description}.failure", gateway_params(params))
      raise e
    end

    def stat(description)
      "#{namespace}.#{description}"
    end
  end
end
