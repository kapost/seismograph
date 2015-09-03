require 'seismograph/gateway'

module Seismograph
  class Sensor
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

    def benchmark(description, params = {})
      Gateway.time(stat(description), gateway_params(params)) do
        yield
      end
    end

    private

    def track(description, amount, params = {}, &block)
      begin
        block.call if block_given?
        Gateway.histogram(stat(description), amount, gateway_params(params))
      rescue StandardError => e
        increment("#{description}.failure", gateway_params(params))
        raise e
      end
    end

    def gateway_params(params)
      params.key?(:tags) ? { tags: Array(params[:tags]) } : { }
    end

    def stat(description)
      "#{namespace}.#{description}"
    end
  end
end
