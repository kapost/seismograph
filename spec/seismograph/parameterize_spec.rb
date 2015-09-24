require 'spec_helper'

RSpec.describe Seismograph::Parameterize do
  subject { klass.new }

  let(:klass) do
    Class.new do
      include Seismograph::Parameterize
      public :gateway_params
    end
  end

  describe '#gateway_params' do
    describe 'when tags is not an array' do
      it 'is converted to an array' do
        expect(subject.gateway_params(tags: 'foo')).to eq(tags: %w[foo])
      end
    end

    describe 'when env is set' do
      before do
        allow(Seismograph.config).to receive(:env).and_return('foo')
      end

      it 'appends env to tags' do
        expect(subject.gateway_params).to eq(tags: %w[env:foo])
      end
    end

    describe 'when tags is empty' do
      it 'does not append tags' do
        expect(subject.gateway_params).to eq({})
      end
    end
  end
end
