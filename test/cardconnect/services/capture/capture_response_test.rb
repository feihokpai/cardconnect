require 'test_helper'

describe CardConnect::Service::CaptureResponse do
  before do
    @response = CardConnect::Service::CaptureResponse.new(valid_capture_response)
  end

  after do
    @response = nil
  end

  describe 'FIELDS' do
    it 'should have merchant id' do
      @response.merchid.must_equal '000000927996'
    end

    it 'should have account' do
      @response.account.must_equal '41XXXXXXXXXX4113'
    end

    it 'should have amount' do
      @response.amount.must_equal '596.00'
    end

    it 'should have retrieval reference number' do
      @response.retref.must_equal '288002073633'
    end

    it 'should have settlement status' do
      @response.setlstat.must_equal 'Pending'
    end
  end

  describe '#body' do
    it 'should generate hash with all the right values' do
      @response.body.must_equal symbolize_keys(valid_capture_response)
    end
  end

  describe '#success?' do
    it 'should be true when the capture was approved' do
      @response.success?.must_equal true
    end

    it 'should be false when the capture was not approved' do
      %w[B C].each do |status|
        response = CardConnect::Service::CaptureResponse.new(
          valid_capture_response.merge('respstat' => status, 'resptext' => 'Not approved')
        )

        response.success?.must_equal false
        response.errors.must_equal ['Not approved']
      end
    end
  end

  describe '#errors' do
    it 'should be empty when the capture was approved' do
      @response.errors.must_be_empty
    end
  end
end
