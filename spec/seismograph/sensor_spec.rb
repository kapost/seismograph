require 'spec_helper'

RSpec.describe Seismograph::Sensor do
  subject { described_class.new('mynamespace') }

  let(:client_double) { double('statsd client', histogram: true, increment: true, decrement: true, time: true, timing: true, gauge: true) }

  before do
    allow(Seismograph::Gateway).to receive(:client).and_return(client_double)
    allow(Seismograph.config).to receive(:env).and_return(nil)

    Seismograph.config do |config|
      config.app_name = 'myapp'
    end
  end

  shared_examples_for 'block instrument' do |method, *args|
    it 'returns the result of the block' do
      r = subject.send(method, *args) do
        'block return value'
      end

      expect(r).to eql('block return value')
    end
  end

  context 'when enabled is false' do
    around do |example|
      begin
        Seismograph.config.enabled = false
        example.run
      ensure
        Seismograph.config.enabled = true
      end
    end

    it 'does not call client' do
      subject.increment('metric', tags: 'sometag')
      expect(client_double).to_not have_received(:increment)
    end
  end

  describe '#increment' do
    it 'accepts tags' do
      subject.increment('metric', tags: 'sometag')
      expect(client_double).to have_received(:increment).once.with('mynamespace.metric', tags: %w[sometag app:myapp])
    end
  end

  describe '#decrement' do
    it 'accepts tags' do
      subject.decrement('metric', tags: 'sometag')
      expect(client_double).to have_received(:decrement).once.with('mynamespace.metric', tags: %w[sometag app:myapp])
    end
  end

  describe '#count' do
    it_behaves_like 'block instrument', :count, 'metric', 5

    it 'requires an amount argument' do
      subject.count('metric', 5)
      expect(client_double).to have_received(:histogram).once.with('mynamespace.metric', 5, tags: %w[app:myapp])
    end

    it 'accepts tags' do
      subject.count('metric', 1, tags: 'sometag')
      expect(client_double).to have_received(:histogram).once.with('mynamespace.metric', 1, tags: %w[sometag app:myapp])
    end

    it 'accepts a block' do
      x = 0
      subject.count('metric', 2) { x = 1 }
      expect(x).to eql(1)
    end

    describe 'when an error is not raised' do
      def count
        subject.count('metric', 2) { }
      end

      it 'tracks histogram' do
        count
        expect(client_double).to have_received(:histogram).once.with('mynamespace.metric', 2, tags: %w[app:myapp])
      end

      it 'increments successes' do
        count
        expect(client_double).to have_received(:increment).once.with('mynamespace.metric.success', tags: %w[app:myapp])
      end
    end

    describe 'when an error is raised' do
      def count
        subject.count('metric', 1) { fail 'My error' }
      end

      it 'does not track histogram' do
        count rescue nil
        expect(client_double).to_not have_received(:histogram)
      end

      it 'increments failures' do
        count rescue nil
        expect(client_double).to have_received(:increment).once.with('mynamespace.metric.failure', tags: %w[app:myapp])
      end

      it 're-raises error' do
        expect { count }.to raise_error(RuntimeError)
      end
    end
  end

  describe '#benchmark' do
    let(:client_double) { double('statsd client', histogram: true, increment: true, decrement: true, time: 'block return value', timing: true, gauge: true) }

    it_behaves_like 'block instrument', :benchmark, 'metric'

    describe 'when an error is not raised' do
      def benchmark
        subject.benchmark('metric') { }
      end

      it 'tracks benchmark time' do
        benchmark
        expect(client_double).to have_received(:time).once.with('mynamespace.metric', tags: %w[app:myapp])
      end

      it 'increments successes' do
        benchmark
        expect(client_double).to have_received(:increment).once.with('mynamespace.metric.success', tags: %w[app:myapp])
      end
    end

    describe 'when an error is raised' do
      def benchmark
        subject.benchmark('metric') { fail 'My error' }
      end

      before do
        allow(client_double).to receive(:time).and_raise(RuntimeError, 'My error')
      end

      it 'tracks benchmark time' do
        benchmark rescue nil
        expect(client_double).to have_received(:time).once.with('mynamespace.metric', tags: %w[app:myapp])
      end

      it 'increments failures' do
        benchmark rescue nil
        expect(client_double).to have_received(:increment).once.with('mynamespace.metric.failure', tags: %w[app:myapp])
      end
    end
  end

  describe '#timing' do
    it 'records the duration' do
      subject.timing('response_time', 5)
      expect(client_double).to have_received(:timing).once.with('mynamespace.response_time', 5, tags: %w[app:myapp])
    end
  end

  describe '#gauge' do
    it 'requires a gauge metric' do
      subject.gauge('my_gauge', 2001)
      expect(client_double).to have_received(:gauge).once.with('mynamespace.my_gauge', 2001, tags: %w[app:myapp])
    end
  end
end
