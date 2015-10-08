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

    def benchmark(description, params = {}, &block)
      with_success_and_failure(description, params) do
        Gateway.time(stat(description), gateway_params(params), &block)
      end
    end

    private

    def track(description, amount, params = {})
      with_success_and_failure(description, params) do
        yield if block_given?
        Gateway.histogram(stat(description), amount, gateway_params(params))
      end
    end

    def with_success_and_failure(description, params)
      yield
      increment("#{description}.success", gateway_params(params))
    rescue StandardError => e
      increment("#{description}.failure", gateway_params(params))
      raise e
    end

    def stat(description)
      "#{namespace}.#{description}"
    end
  end
end
