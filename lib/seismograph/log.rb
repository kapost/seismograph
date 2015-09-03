module Seismograph
  module Log
    class << self
      [:info, :error, :warning, :success].each do |alert_type|
        define_method alert_type do |message, params = {}|
          description = params.delete(:description) || ''
          log(message, description, params.merge(alert_type: alert_type.to_s))
        end
      end

      private

      def log(message, description, params)
        params[:tags] = Array(params[:tags]) if params.key?(:tags)
        
        Gateway.event(
          message,
          description,
          params.merge(
            source_type_name: Seismograph.config.app_name
          )
        )
      end
    end
  end
end
