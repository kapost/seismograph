require 'spec_helper'

RSpec.describe Seismograph::Log do
  subject { described_class }

  let(:client_double) { double('statsd client', event: true) }

  before do
    allow(Seismograph::Gateway).to receive(:client).and_return(client_double)
    allow(Seismograph.config).to receive(:env).and_return(nil)

    Seismograph.config do |config|
      config.app_name = 'myapp'
    end
  end

  shared_examples_for 'alert type method' do |alert_type|
    it 'sends event with specified alert type' do
      subject.send(alert_type, 'Hey wtf')
      expect(client_double).to have_received(:event).once.with('Hey wtf', '', source_type_name: 'myapp', alert_type: alert_type.to_s, tags: %w[app:myapp])
    end

    it 'allows tags' do
      subject.send(alert_type, 'Hey wtf with tags', tags: 'superman')
      expect(client_double).to have_received(:event).once.with('Hey wtf with tags', '', source_type_name: 'myapp', alert_type: alert_type.to_s, tags: %w[superman app:myapp])
    end

    it 'allows description' do
      subject.send(alert_type, 'Hey wtf with description', description: 'batcave')
      expect(client_double).to have_received(:event).once.with('Hey wtf with description', 'batcave', source_type_name: 'myapp', alert_type: alert_type.to_s, tags: %w[app:myapp])
    end
  end

  describe '#error' do
    it_behaves_like 'alert type method', :error
  end

  describe '#info' do
    it_behaves_like 'alert type method', :info
  end

  describe '#warning' do
    it_behaves_like 'alert type method', :warning
  end

  describe '#success' do
    it_behaves_like 'alert type method', :success
  end
end
