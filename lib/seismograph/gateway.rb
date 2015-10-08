require 'statsd'

module Seismograph
  module Gateway
    class << self
      [:histogram, :increment, :decrement, :time, :event].each do |method|
        define_method(method) do |*args, &block|
          client.send(method, *args, &block)
        end
      end

      private

      def client
        @client ||= Statsd.new(Seismograph.config.statsd_host,
                               Seismograph.config.statsd_port,
                               namespace: Seismograph.config.app_name)
      end
    end
  end
end
