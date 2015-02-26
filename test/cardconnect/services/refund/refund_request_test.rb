require 'test_helper'

describe CardConnect::Service::RefundRequest do
  before do
    @request = CardConnect::Service::RefundRequest.new(valid_refund_request)
    @valid_payload = symbolize_keys(valid_refund_request)
  end

  after do
    @request = nil
  end

  describe 'FIELDS' do
    it 'should have merchant id' do
      @request.merchid.must_equal @valid_payload[:merchid]
    end

    it 'should have retrieval reference number' do
      @request.retref.must_equal @valid_payload[:retref]
    end

    it 'should have amount' do
      @request.amount.must_equal @valid_payload[:amount]
    end
  end

  describe '#valid?' do
    it 'should not be valid if no attributes are passed in' do
      CardConnect::Service::RefundRequest.new.valid?.must_equal false
    end

    it 'should be valid if valid attributes are passed in' do
      CardConnect::Service::RefundRequest.new(valid_refund_request).valid?.must_equal true
    end
  end

  describe '#errors' do
    CardConnect::Service::RefundRequest::REQUIRED_FIELDS.each do |field|
      it "should have an error message if #{field} is missing" do
        CardConnect::Service::RefundRequest.new.errors.must_include "#{field.to_s.capitalize} is missing"
      end
    end
  end

  describe '#payload' do
    it 'should generate hash with all the right values' do
      @request.payload.keys.each do |k|
        @request.payload[k].must_equal @valid_payload[k]
      end
    end
  end
end
