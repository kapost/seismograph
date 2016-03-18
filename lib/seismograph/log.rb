require 'seismograph/gateway'
require 'seismograph/parameterize'

module Seismograph
  module Log
    class << self
      include Parameterize

      [:info, :error, :warning, :success].each do |alert_type|
        class_eval <<-RUBY, __FILE__, __LINE__+1
          def #{alert_type}(message, params = {})
            description = params.delete(:description) || ''
            log(message, description, params.merge(alert_type: "#{alert_type}"))
          end
        RUBY
      end

      private

      def log(message, description, params)
        params = gateway_params(params).merge(source_type_name: Seismograph.config.app_name)
        Gateway.event(message, description, params)
      end
    end
  end
end
