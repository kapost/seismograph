require 'statsd'

module Seismograph
  module Gateway
    class << self
      [:histogram, :increment, :decrement, :time, :event, :gauge].each do |method|
        class_eval <<-RUBY, __FILE__, __LINE__+1
          def #{method}(*a, &b)
            client.send(:#{method}, *a, &b)
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
