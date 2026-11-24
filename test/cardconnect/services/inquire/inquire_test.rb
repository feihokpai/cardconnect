require 'test_helper'

describe CardConnect::Service::Inquire do
  before do
    @connection = CardConnect::Connection.new.connection do |stubs|
      path = "#{@service.path}/#{valid_inquire_request['retref']}/#{valid_inquire_request['merchid']}"
      stubs.get(path) { [200, {}, valid_inquire_response] }
    end
    @service = CardConnect::Service::Inquire.new(@connection)
  end

  after do
    @service = nil
  end

  it 'must have the right path' do
    @service.path.must_equal '/cardconnect/rest/inquire'
  end

  describe '#build_request' do
    before do
      @valid_params = valid_inquire_request
    end

    after do
      @valid_params = nil
    end

    it 'creates a inquire request object with the passed in params' do
      @service.build_request(@valid_params)

      @service.request.must_be_kind_of CardConnect::Service::InquireRequest
      @service.request.retref.must_equal '288002073633'
      @service.request.merchid.must_equal '000000927996'
    end

    it 'uses default merchant ID if merchid is not passed in' do
      @service.build_request(@valid_params.reject! { |k, _| k == 'merchid' })
      @service.request.must_be_kind_of CardConnect::Service::InquireRequest
      @service.request.merchid.must_equal 'merchant123'
    end
  end

  describe '#submit' do
    it 'raises an error when there is no request' do
      @service.request.nil?.must_equal true
      proc { @service.submit }.must_raise CardConnect::Error
    end

    it 'creates a response when a valid request is processed' do
      @service.build_request(valid_inquire_request)
      @service.submit
      @service.response.must_be_kind_of CardConnect::Service::InquireResponse
    end

    it 'returns nil when the api responds with not found' do
      not_found = [404, { 'Content-Type' => 'application/json' }, '{"resptext":"Not found"}']
      path = "/cardconnect/rest/inquire/#{valid_inquire_request['retref']}/#{valid_inquire_request['merchid']}"

      connection = CardConnect::Connection.new.connection do |stubs|
        stubs.get(path) { not_found }
      end

      service = CardConnect::Service::Inquire.new(connection)
      service.build_request(valid_inquire_request)

      capture_io { service.submit.must_be_nil }
      service.response.must_be_nil
    end

    it 'raises the client error when the api rejects the credentials' do
      unauthorized = [401, { 'Content-Type' => 'application/json' }, '{"resptext":"Unauthorized"}']
      path = "/cardconnect/rest/inquire/#{valid_inquire_request['retref']}/#{valid_inquire_request['merchid']}"

      connection = CardConnect::Connection.new.connection do |stubs|
        stubs.get(path) { unauthorized }
      end

      service = CardConnect::Service::Inquire.new(connection)
      service.build_request(valid_inquire_request)

      proc { service.submit }.must_raise Faraday::UnauthorizedError
      service.response.must_be_nil
    end
  end
end
