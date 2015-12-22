require 'spec_helper'

RSpec.describe SparkPost::Transmission do
  describe '#initialize' do 
    context 'when api key and host are passed'
    let(:transmission) { SparkPost::Transmission.new('123', 'http://sparkpost.com') }

    it { expect(transmission.instance_variables).to include(:@api_key) }
    it { expect(transmission.instance_variables).to include(:@api_host) }
    it { expect(transmission.instance_variable_get(:@api_key)).to eq('123') }
    it { expect(transmission.instance_variable_get(:@api_host)).to eq('http://sparkpost.com') }

    context 'when api key or host not passed' do 
        it {expect {SparkPost::Transmission.new }.to raise_error(ArgumentError) }
        it {expect {SparkPost::Transmission.new(123) }.to raise_error(ArgumentError) }
    end
  end

  describe '#send_message' do 
    let(:transmission) { SparkPost::Transmission.new('123456', 'https://api.sparkpost.com')}
    let(:url) { 'https://api.sparkpost.com/api/v1/transmissions' }
    before do 
        allow(transmission).to receive(:request).and_return({})
    end

    it 'requests correct endpoint' do 
        allow(transmission).to receive(:request) do |_url|
            expect(_url).to eq(url)
        end

        transmission.send_message('to@example.com', 'from@example.com', 'test subject', '<h1>Hello World</h1>')
    end

    it 'requests with correct parameters' do 
        allow(transmission).to receive(:request) do |_url, api_key, data| 
            expect(data[:recipients].length).to eq(1)
            expect(data[:recipients][0][:address]).to eq({email: 'to@example.com'})
            expect(data[:content][:from]).to eq('from@example.com')
            expect(data[:content][:subject]).to eq('test subject')
            expect(data[:content][:html]).to eq('<h1>Hello World</h1>')
        end
        transmission.send_message('to@example.com', 'from@example.com', 'test subject', '<h1>Hello World</h1>')
    end

    it 'handles array of recipients correctly' do 
        allow(transmission).to receive(:request) do |_url, api_key, data| 
            expect(data[:recipients].length).to eq(1)
            expect(data[:recipients][0][:address]).to eq({email: 'to@example.com'})
        end
        transmission.send_message(['to@example.com'], 'from@example.com', 'test subject', '<h1>Hello World</h1>')
    end

    it { expect {transmission.send_message(['to@example.com'], 'from@example.com', 'test subject')}.to raise_error(ArgumentError).with_message(/Content missing/) }
    it { expect {transmission.send_message(['to@example.com'], 'from@example.com', 'test subject', nil, {text_message: 'hello world'})}.to_not raise_error }

    it 'passes through delivery exception' do 
        allow(transmission).to receive(:request).and_raise(SparkPost::DeliveryException.new('Some delivery error'))

        expect { transmission.send_message('to@example.com', 'from@example.com', 'test subject', '<h1>Hello World</h1>')}.to raise_error(SparkPost::DeliveryException).with_message(/Some delivery error/)
    end

    it 'passes responses' do 
        allow(transmission).to receive(:request).and_return({success: 1})
        expect(transmission.send_message('to@example.com', 'from@example.com', 'test subject', '<h1>Hello World</h1>')).to eq({success: 1})
    end
  end
end
