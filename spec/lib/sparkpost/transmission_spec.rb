require 'spec_helper'

RSpec.describe SparkPost::Transmission do
  describe '#initialize' do
    context 'when api key and host are passed'
    let(:transmission) do
      SparkPost::Transmission.new('123', 'http://sparkpost.com')
    end

    it { expect(transmission.instance_variables).to include(:@api_key) }
    it { expect(transmission.instance_variables).to include(:@api_host) }
    it { expect(transmission.instance_variable_get(:@api_key)).to eq('123') }
    it do
      expect(transmission.instance_variable_get(:@api_host))
        .to eq('http://sparkpost.com')
    end

    context 'when api key or host not passed' do
      it do
        expect { SparkPost::Transmission.new }
          .to raise_error(ArgumentError)
      end
      it do
        expect { SparkPost::Transmission.new(123) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#send_message' do
    let(:transmission) do
      SparkPost::Transmission.new('123456', 'https://api.sparkpost.com')
    end
    let(:url) { 'https://api.sparkpost.com/api/v1/transmissions' }
    before do
      allow(transmission).to receive(:request).and_return({})
    end

    it 'requests correct endpoint' do
      allow(transmission).to receive(:request) do |request_url|
        expect(request_url).to eq(url)
      end

      transmission.send_message(
        'to@example.com',
        'from@example.com',
        'test subject',
        '<h1>Hello World</h1>')
    end

    it 'requests with correct parameters' do
      allow(transmission).to receive(:request) do |_url, _api_key, data|
        expect(data[:recipients].length).to eq(1)
        expect(data[:recipients][0][:address]).to eq(email: 'to@example.com')
        expect(data[:content][:from]).to eq('from@example.com')
        expect(data[:content][:subject]).to eq('test subject')
        expect(data[:content][:html]).to eq('<h1>Hello World</h1>')
      end
      transmission.send_message(
        'to@example.com',
        'from@example.com',
        'test subject',
        '<h1>Hello World</h1>')
    end

    it 'handles a recipient hash with email, name and header_to correctly' do
      allow(transmission).to receive(:request) do |_url, _api_key, data|
        expect(data[:recipients].length).to eq(1)
        expect(data[:recipients][0][:address]).to eq(email: 'to@me.com',
                                                     name: 'Me',
                                                     header_to: 'no@reply.com'
                                                    )
      end
      transmission.send_message(
        { email: 'to@me.com', name: 'Me', header_to: 'no@reply.com' },
        'from@example.com',
        'test subject',
        '<h1>Hello World</h1>')
    end

    it 'handles an invalid recipient hash' do
      expect do
        transmission.send_message(
          { name: 'Me', header_to: 'no@reply.com' },
          'from@example.com',
          'test subject',
          '<h1>Hello World</h1>')
      end.to raise_error(/email missing/)
    end

    it 'handles array of recipients correctly' do
      allow(transmission).to receive(:request) do |_url, _api_key, data|
        expect(data[:recipients].length).to eq(1)
        expect(data[:recipients][0][:address]).to eq(email: 'to@example.com')
      end
      transmission.send_message(
        ['to@example.com'],
        'from@example.com',
        'test subject',
        '<h1>Hello World</h1>')
    end

    it 'handles array of recipient hashess correctly' do
      allow(transmission).to receive(:request) do |_url, _api_key, data|
        expect(data[:recipients].length).to eq(1)
        expect(data[:recipients][0][:address]).to eq(email: 'to@me.com',
                                                     name: 'Me',
                                                     header_to: 'no@reply.com'
                                                    )
      end
      transmission.send_message(
        [{ email: 'to@me.com', name: 'Me', header_to: 'no@reply.com' }],
        'from@example.com',
        'test subject',
        '<h1>Hello World</h1>')
    end

    it 'handles an array of invalid recipient hashes' do
      expect do
        transmission.send_message(
          [
            { to: 'to@me.com', name: 'Me', header_to: 'no@reply.com' },
            { name: 'You', header_to: 'no@reply.com' }
          ],
          'from@example.com',
          'test subject',
          '<h1>Hello World</h1>')
      end.to raise_error(/email missing/)
    end

    it do
      expect do
        transmission.send_message(
        ['to@example.com'],
        'from@example.com',
        'test subject')
      end.to raise_error(ArgumentError).with_message(/Content missing/)
    end
    it do
      expect do
        transmission.send_message(
        ['to@example.com'],
        'from@example.com',
        'test subject',
        nil,
        text_message: 'hello world')
      end.to_not raise_error
    end

    it 'passes through delivery exception' do
      allow(transmission).to receive(:request).and_raise(
        SparkPost::DeliveryException.new('Some delivery error'))

      expect do
        transmission.send_message(
        'to@example.com',
        'from@example.com',
        'test subject',
        '<h1>Hello World</h1>')
      end.to raise_error(SparkPost::DeliveryException).with_message(
        /Some delivery error/)
    end

    it 'passes responses' do
      allow(transmission).to receive(:request).and_return(success: 1)
      expect(transmission.send_message(
        'to@example.com',
        'from@example.com',
        'test subject',
        '<h1>Hello World</h1>')).to eq(success: 1)
    end

    it 'sends attachments' do
      attachment = {
        name: 'attachment.txt',
        type: 'text/plain',
        data: Base64.encode64('Hello World')
      }
      options = {
        attachments: [attachment]
      }

      allow(transmission).to receive(:request) do |_url, _api_key, data|
        expect(data[:content][:attachments]).to be_kind_of(Array)
        expect(data[:content][:attachments].length).to eq(1)
        expect(data[:content][:attachments][0]).to eq(attachment)
      end
      transmission.send_message(
        ['to@example.com'],
        'from@example.com',
        'test subject',
        '<h1>Hello World</h1>',
        options)
    end
  end
end
