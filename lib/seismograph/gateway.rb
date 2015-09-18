require 'statsd'

module Seismograph
  module Gateway
    class << self
      [:histogram, :increment, :time, :event].each do |method|
        define_method(method) do |*args|
          client.send(method, *args)
        end
      end

      private

      def client
        @client ||= Statsd.new(Seismograph.config.statsd_host,
                               Seismograph.config.statsd_port,
                               namespace: [Seismograph.config.app_name, Seismograph.config.env].join('.'))
      end
    end
  end
end
