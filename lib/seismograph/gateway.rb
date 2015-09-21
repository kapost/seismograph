require 'statsd'

module Seismograph
  module Gateway
    class << self
      [:histogram, :increment, :time, :event].each do |method|
        define_method(method) do |*args, &block|
          client.send(method, *args, &block)
        end
      end

      private

      def client
        @client ||= Statsd.new(Seismograph.config.statsd_host,
                               Seismograph.config.statsd_port,
                               namespace: namespace)
      end

      def namespace
        [
          Seismograph.config.app_name,
          Seismograph.config.env
        ].compact.join('.')
      end
    end
  end
end
