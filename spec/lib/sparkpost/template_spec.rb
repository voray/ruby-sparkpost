require 'spec_helper'

RSpec.describe SparkPost::Template do
  describe '#initialize' do
    context 'when api key and host are passed'
    let(:template) do
      SparkPost::Template.new('123', 'http://sparkpost.com')
    end

    it { expect(template.instance_variables).to include(:@api_key) }
    it { expect(template.instance_variables).to include(:@api_host) }
    it { expect(template.instance_variable_get(:@api_key)).to eq('123') }
    it do
      expect(template.instance_variable_get(:@api_host))
        .to eq('http://sparkpost.com')
    end

    it 'has correct path' do
      expect(template.class::PATH).to eq('/api/v1/templates')
    end

    context 'when api key or host not passed' do
      it do
        expect { SparkPost::Template.new }
          .to raise_error(ArgumentError)
      end
      it do
        expect { SparkPost::Template.new(123) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#list' do
    let(:template) do
      SparkPost::Template.new('123456', 'https://api.sparkpost.com')
    end
    let(:url) { 'https://api.sparkpost.com/api/v1/templates' }

    it 'calls request with correct data' do
      allow(template).to receive(:request) do |req_url, req_api_key, _req_data, req_verb|
        expect(req_verb).to eq('GET')
        expect(req_api_key).to eq('123456')
        expect(req_url).to eq(url)
      end

      template.list
    end
  end
end
