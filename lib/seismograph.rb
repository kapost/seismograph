require 'seismograph/configuration'
require 'seismograph/sensor'
require 'seismograph/log'

module Seismograph
  def self.config(&block)
    @config ||= Configuration.new
    block.call(@config) if block_given?
    @config
  end
end
