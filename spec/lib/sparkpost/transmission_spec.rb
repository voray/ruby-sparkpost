require 'spec_helper'

RSpec.describe SparkPost::Transmission do
  describe '#api_key' do 
    let(:transmission) { SparkPost::Transmission.new(api_key='123') }

    context 'when api key is explicitly passed' do
        it { expect(transmission.instance_variables).to include(:@api_key) }
        it { expect(transmission.instance_variable_get(:@api_key)).to eq('123') }
    end

    context 'when api key passed via env variable' do 
        before do 
            ENV['SPARKPOST_API_KEY'] = '456'
        end
        let(:transmission) do 
            
            SparkPost::Transmission.new
        end
        it { expect(transmission.instance_variable_get(:@api_key)).to eq('456')}
    end

    context 'when api key not available at all' do 
        before do 
            ENV['SPARKPOST_API_KEY'] = nil
        end
        it {expect {SparkPost::Transmission.new  }.to raise_error(SparkPost::Exception).with_message(/No API key provided/)}
    end
  end

  describe '#transmit' do 
    # let(:transmission) { SparkPost::Transmission.new(api_key='123456')}
    # let(:transmission) { instance_double('SparkPost::Transmission', '123456')}
  end
end