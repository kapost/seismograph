module Seismograph
  module Parameterize
    protected

    def gateway_params(params = {})
      env = Seismograph.config.env

      params.dup.tap do |p|
        p[:tags] = Array(params[:tags])
        p[:tags] << "env:#{env}" unless env.nil?
        p.delete(:tags) if p[:tags].empty?
      end
    end
  end
end
