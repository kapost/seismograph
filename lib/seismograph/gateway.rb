require 'statsd'

module Seismograph
  module Gateway
    GATEWAY_METHODS = [:histogram, :increment, :decrement, :time, :timing, :event, :gauge].freeze

    class << self
      GATEWAY_METHODS.each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__+1
          def #{method}(*a, &b)
            client.send(:#{method}, *a, &b) if Seismograph.config.enabled
          end
        RUBY
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
