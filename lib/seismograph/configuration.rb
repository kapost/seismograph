module Seismograph
  class Configuration
    attr_writer :statsd_host
    attr_writer :statsd_port
    attr_writer :app_name
    attr_writer :env

    def statsd_host=(host)
      @statsd_host = host
    end

    def statsd_port=(port)
      @statsd_port = port.to_s
    end

    def app_name=(name)
      @app_name = name
    end

    def env=(env)
      @env = env
    end

    def statsd_host
      @statsd_host || fail('No statsd_host configured')
    end

    def statsd_port
      @statsd_port || fail('No statsd_port configured')
    end

    def app_name
      @app_name || fail('No app_name configured')
    end

    def env
      @env || ENV['RAILS_ENV'] || ENV['RACK_ENV']
    end
  end
end
