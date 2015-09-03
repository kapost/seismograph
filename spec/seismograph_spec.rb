require 'spec_helper'

RSpec.describe Seismograph, type: :model do
  subject { described_class }

  describe '.config' do
    it 'returns a configuration object' do
      expect(subject.config).to be_a Seismograph::Configuration
    end

    it 'always returns the same object' do
      expect(subject.config).to be subject.config
    end

    it 'accepts a block' do
      subject.config { |c| c.app_name = 'foo' }

      expect(subject.config.app_name).to eql('foo')
    end

    it 'requires a statsd_host' do
      expect {
        subject.config.statsd_host
      }.to raise_error RuntimeError
    end
  end
end
