require 'spec_helper'

describe SparkPost::DeliveryException do
  subject { SparkPost::DeliveryException.new(error) }

  describe 'hash' do
    let(:error) { { 'errors' => { 'message' => 'end of world' } } }

    it 'preserves original message' do
      begin
        raise subject
      rescue SparkPost::DeliveryException => err
        expect(error.to_s).to eq(err.message)
      end
    end
  end

  describe 'string' do
    let(:error) { 'Some delivery error' }

    it 'preserves original message' do
      begin
        raise subject
      rescue SparkPost::DeliveryException => err
        expect(error).to eq(err.message)
      end
    end
  end

  describe 'array with error details' do
    let(:error) { [{ 'message' => 'Message generation rejected', 'description' => 'recipient address suppressed due to customer policy', 'code' => '1902' }] }

    it 'assigns message' do
      expect(subject.service_message).to eq('Message generation rejected')
    end

    it 'assigns description' do
      expect(subject.service_description).to eq('recipient address suppressed due to customer policy')
    end

    it 'assigns code' do
      expect(subject.service_code).to eq('1902')
    end

    it 'preserves original message' do
      begin
        raise subject
      rescue SparkPost::DeliveryException => err
        expect(error.to_s).to eq(err.message)
      end
    end
  end
end
