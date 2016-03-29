require 'spec_helper'

RSpec.describe SparkPost::Api do
  let(:api) { api = SparkPost::Api.new('123', 'https://api.sparkpost.com') }

  describe '#initialize' do
    context 'when api key and host are passed'

    it { expect(api.instance_variables).to include(:@api_key) }
    it { expect(api.instance_variables).to include(:@api_host) }
    it { expect(api.instance_variable_get(:@api_key)).to eq('123') }
    it do
      expect(api.instance_variable_get(:@api_host))
        .to eq('https://api.sparkpost.com')
    end

    it 'has empty endpoint' do
      expect(api.class::PATH).to eq('')
    end

    context 'when api key or host not passed' do
      it do
        expect { SparkPost::Api.new }
          .to raise_error(ArgumentError)
      end
      it do
        expect { SparkPost::Api.new(123) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#api_url' do
    let(:url) { 'https://api.sparkpost.com' }

    it 'returns correct request url' do
      expect(api.api_url).to eq(url)
    end

    it 'returns correct request url on subsequent calls' do
      api.api_url

      expect(api.api_url).to eq(url)
    end
  end

  describe '#send_payload' do
    let(:url) { 'https://api.sparkpost.com' }
    let(:data) do
      {
        recipients: [
          {
            address: {
              email: 'to@me.com', name: 'Me', header_to: 'no@reply.com'
            }
          }
        ],
        content: {
          from: { email: 'me@me.com', name: 'Me' },
          subject: 'test subject',
          text: 'Hello Sparky',
          html: '<h1>Hello Sparky</h1>'
        }
      }
    end

    it 'calls request with correct data' do
      allow(api).to receive(:request) do |req_url, req_api_key, req_data|
        expect(req_api_key).to eq('123')
        expect(req_url).to eq(url)
        expect(req_data).to eq(data)
      end

      api.send_payload(data)
    end

    it 'passes through delivery exception' do
      allow(api).to receive(:request).and_raise(
        SparkPost::DeliveryException.new('Some delivery error'))

      bad_data = data.merge(recipients: [])

      expect do
        api.send_payload(bad_data)
      end.to raise_error(SparkPost::DeliveryException).with_message(
        /Some delivery error/)
    end

    it 'passes responses' do
      allow(api).to receive(:request).and_return(success: 1)
      expect(api.send_payload(data)).to eq(success: 1)
    end
  end
end
