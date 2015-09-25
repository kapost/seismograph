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
    before do
      allow(Seismograph.config).to receive(:app).and_return('myapp')
      allow(Seismograph.config).to receive(:env).and_return(nil)
    end

    describe 'when tags is not an array' do
      it 'is converted to an array' do
        expect(subject.gateway_params(tags: 'sometag')).to eq(tags: %w[sometag app:myapp])
      end
    end

    describe 'when env is set' do
      before do
        allow(Seismograph.config).to receive(:env).and_return('sometag')
      end

      it 'appends app and env to tags' do
        expect(subject.gateway_params).to eq(tags: %w[app:myapp env:sometag])
      end
    end

    describe 'when tags is empty' do
      it 'appends app to tags' do
        expect(subject.gateway_params).to eq(tags: %w[app:myapp])
      end
    end
  end
end
