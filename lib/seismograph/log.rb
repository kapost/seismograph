require 'seismograph/parameterize'

module Seismograph
  module Log
    class << self
      include Parameterize

      [:info, :error, :warning, :success].each do |alert_type|
        define_method alert_type do |message, params = {}|
          description = params.delete(:description) || ''
          log(message, description, params.merge(alert_type: alert_type.to_s))
        end
      end

      private

      def log(message, description, params)
        params = gateway_params(params).merge(source_type_name: Seismograph.config.app_name)
        Gateway.event(message, description, params)
      end
    end
  end
end
