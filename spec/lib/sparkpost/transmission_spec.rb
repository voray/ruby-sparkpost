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
        let(:transmission) { SparkPost::Transmission.new }
        it { expect(transmission.instance_variable_get(:@api_key)).to eq('456')}
    end

    context 'when api key not available at all' do 
        before do 
            ENV['SPARKPOST_API_KEY'] = nil
        end
        it {expect {SparkPost::Transmission.new  }.to raise_error(ArgumentError).with_message(/No API key provided/)}
    end
  end

  describe '#transmit' do 
    let(:transmission) { SparkPost::Transmission.new(api_key='123456')}
    let(:url) { 'https://api.sparkpost.com/api/v1/transmissions' }
    before do 
        allow(transmission).to receive(:request).and_return({})
    end

    it 'requests correct endpoint' do 
        allow(transmission).to receive(:request) do |_url|
            expect(_url).to eq(url)
        end

        transmission.transmit('to@example.com', 'from@example.com', 'test subject', '<h1>Hello World</h1>')
    end

    it 'requests with correct parameters' do 
        allow(transmission).to receive(:request) do |_url, data| 
            expect(data[:recipients].length).to eq(1)
            expect(data[:recipients][0][:address]).to eq({email: 'to@example.com'})
            expect(data[:content][:from]).to eq('from@example.com')
            expect(data[:content][:subject]).to eq('test subject')
            expect(data[:content][:html]).to eq('<h1>Hello World</h1>')
        end
        transmission.transmit('to@example.com', 'from@example.com', 'test subject', '<h1>Hello World</h1>')
    end

    it 'handles array of recipients correctly' do 
        allow(transmission).to receive(:request) do |_url, data| 
            expect(data[:recipients].length).to eq(1)
            expect(data[:recipients][0][:address]).to eq({email: 'to@example.com'})
        end
        transmission.transmit(['to@example.com'], 'from@example.com', 'test subject', '<h1>Hello World</h1>')
    end

    it { expect {transmission.transmit(['to@example.com'], 'from@example.com', 'test subject')}.to raise_error(ArgumentError).with_message(/Content missing/) }
    it { expect {transmission.transmit(['to@example.com'], 'from@example.com', 'test subject', nil, {text_message: 'hello world'})}.to_not raise_error }

    it 'passes through delivery exception' do 
        allow(transmission).to receive(:request).and_raise(SparkPost::DeliveryException.new('Some delivery error'))

        expect { transmission.transmit('to@example.com', 'from@example.com', 'test subject', '<h1>Hello World</h1>')}.to raise_error(SparkPost::DeliveryException).with_message(/Some delivery error/)
    end

    it 'passes responses' do 
        allow(transmission).to receive(:request).and_return({success: 1})
        expect(transmission.transmit('to@example.com', 'from@example.com', 'test subject', '<h1>Hello World</h1>')).to eq({success: 1})
    end
  end
end