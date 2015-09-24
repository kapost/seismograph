require 'spec_helper'

RSpec.describe Seismograph::Sensor do
  subject { described_class.new('mynamespace') }

  let(:client_double) { double('statsd client', histogram: true, increment: true, time: true) }

  before do
    allow(Seismograph::Gateway).to receive(:client).and_return(client_double)
    allow(Seismograph.config).to receive(:env).and_return(nil)
  end

  describe '#count' do
    it 'requires an amount argument' do
      subject.count('metric', 5)
      expect(client_double).to have_received(:histogram).once.with('mynamespace.metric', 5, {})
    end

    it 'accepts tags' do
      subject.count('metric', 1, tags: 'sometag')
      expect(client_double).to have_received(:histogram).once.with('mynamespace.metric', 1, tags: ['sometag'])
    end

    it 'accepts a block' do
      x = 0
      subject.count('metric', 2) do
        x = 1
      end

      expect(x).to eql(1)
      expect(client_double).to have_received(:histogram).once.with('mynamespace.metric', 2, {})
    end

    it 'increments failures if exception is thrown' do
      subject.count('metric', 1) do
        fail 'My error'
      end rescue nil

      expect(client_double).to have_received(:increment).once.with('mynamespace.metric.failure', {})
    end

    it 're-raises error' do
      expect {
        subject.count('metric', 4) do
          fail 'My error'
        end
      }.to raise_error(RuntimeError)
    end
  end

  describe '#increment' do
    it 'accepts tags' do
      subject.increment('metric', tags: 'sometag')
      expect(client_double).to have_received(:increment).once.with('mynamespace.metric', tags: ['sometag'])
    end
  end

  describe '#benchmark' do
    it 'benchmark time' do
      subject.benchmark('metric') do
        # Slow stuff
      end
      expect(client_double).to have_received(:time).once.with('mynamespace.metric', {})
    end
  end
end
