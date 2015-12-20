require 'spec_helper'

RSpec.describe SparkPost::Transmission do
  describe '#initialize' do 
    context 'when api key and host are passed'
    let(:client) { SparkPost::Client.new('123', 'http://sparkpost.com') }

    it { expect(client.instance_variables).to include(:@api_key) }
    it { expect(client.instance_variables).to include(:@api_host) }
    it { expect(client.instance_variable_get(:@api_key)).to eq('123') }
    it { expect(client.instance_variable_get(:@api_host)).to eq('http://sparkpost.com') }

    context 'when api key not passed' do 
        before do 
             ENV['SPARKPOST_API_KEY'] = nil
        end
        it { expect {SparkPost::Client.new }.to raise_error(ArgumentError) }
    end

    context 'when api host not passed' do 
        before do 
             ENV['SPARKPOST_API_HOST'] = nil
        end
        it { expect(SparkPost::Client.new('abc').instance_variable_get(:@api_host)).to eq('https://api.sparkpost.com') }
        it { expect { SparkPost::Client.new('abc', nil) }.to raise_error(ArgumentError) }
    end
  end

  describe '#transmission' do 
    let(:client) { SparkPost::Client.new('123', 'http://sparkpost.com') }

    it { expect(client.transmission).to be_kind_of(SparkPost::Transmission) }

    it 'returns same instances on subsequent call' do 
       expect(client.transmission).to eq(client.transmission) 
    end

  end
end