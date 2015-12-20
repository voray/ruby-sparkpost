require 'spec_helper'

RSpec.describe SparkPost::Request do
    describe '#request' do 
        api_url = 'https://api.sparkpost.com/api/'

        let(:api_key) { '123' }
        let(:request) { SparkPost::Request.request }

        context 'when was successful' do 
            response = {results: {"total_rejected_recipients"=>0, "total_accepted_recipients"=>1, "id"=>"102238681582044821"} }
            before do 
                stub_request(:post, api_url).to_return(body: response.to_json, status: 200)
            end
            it { expect(SparkPost::Request.request(api_url, '123', {})).to eq(response[:results]) }
        end
        context 'when was not successful' do 
            response = {errors: {message: 'end of world'} }
            before do 
                stub_request(:post, api_url).to_return(body: response.to_json, status: 500)
            end

            it { expect { SparkPost::Request.request(api_url, '123', {})}.to raise_error(SparkPost::DeliveryException).with_message(/end of world/) }
        end
    end
end 
