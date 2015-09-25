module Seismograph
  module Parameterize
    protected

    def gateway_params(params = {})
      app = Seismograph.config.app_name
      env = Seismograph.config.env

      params.dup.tap do |p|
        p[:tags] = Array(params[:tags])
        p[:tags] << "app:#{app}"
        p[:tags] << "env:#{env}" unless env.nil?
        p[:tags].uniq!
      end
    end
  end
end
