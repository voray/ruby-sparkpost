require 'spec_helper'

RSpec.describe SparkPost::SuppressionList do
  describe '#initialize' do
    context 'when api key and host are passed'
    let(:suppression_list) do
      SparkPost::Template.new('123', 'http://sparkpost.com')
    end

    it { expect(suppression_list.instance_variables).to include(:@api_key) }
    it { expect(suppression_list.instance_variables).to include(:@api_host) }
    it { expect(suppression_list.instance_variable_get(:@api_key)).to eq('123') }
    it do
      expect(suppression_list.instance_variable_get(:@api_host))
        .to eq('http://sparkpost.com')
    end

    context 'when api key or host not passed' do
      it 'raises when api key and host not passed' do
        expect { SparkPost::SuppressionList.new }
          .to raise_error(ArgumentError)
      end
      it 'raises when host not passed' do
        expect { SparkPost::SuppressionList.new(123) }
          .to raise_error(ArgumentError)
      end
    end
  end

  describe '#endpoint' do
    let(:suppression_list) do
      SparkPost::SuppressionList.new('123456', 'https://api.sparkpost.com')
    end
    let(:url) { 'https://api.sparkpost.com/api/v1/suppression-list' }

    it 'returns correct endpoint' do
      expect(suppression_list.endpoint).to eq(url)
    end

    it 'returns correct endpoint on subsequent calls' do
      suppression_list.endpoint

      expect(suppression_list.endpoint).to eq(url)
    end
  end

  describe '#search' do
    let(:suppression_list) do
      SparkPost::SuppressionList.new('123456', 'https://api.sparkpost.com')
    end

    it 'calls request with correct params when there are array values' do
      allow(suppression_list).to receive(:request) do |req_url, req_api_key, req_data, req_verb|
        expect(req_url).to eq('https://api.sparkpost.com/api/v1/suppression-list?to=t&from=f&types=t,T&sources=s,S&limit=5')
        expect(req_api_key).to eq('123456')
        expect(req_data).to eq({})
        expect(req_verb).to eq('GET')
      end

      suppression_list.search(from: 'f', to: 't', types: %w('t' 'T'), sources: %w('s', 'S'), limit: '5')
    end

    it 'calls request with correct params when there are single values' do
      allow(suppression_list).to receive(:request) do |req_url, req_api_key, req_data, req_verb|
        expect(req_url).to eq('https://api.sparkpost.com/api/v1/suppression-list?to=t&from=f&types=t&sources=t&limit=5')
        expect(req_api_key).to eq('123456')
        expect(req_data).to eq({})
        expect(req_verb).to eq('GET')
      end

      suppression_list.search(from: 'f', to: 't', types: 't', sources: 't', limit: '5')
    end

    it 'calls request with the correct params when there are no values' do
      allow(suppression_list).to receive(:request) do |req_url, req_api_key, req_data, req_verb|
        expect(req_url).to eq('https://api.sparkpost.com/api/v1/suppression-list')
        expect(req_api_key).to eq('123456')
        expect(req_data).to eq({})
        expect(req_verb).to eq('GET')
      end

      suppression_list.search
    end
  end
end
