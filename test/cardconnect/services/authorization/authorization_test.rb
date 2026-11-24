require 'test_helper'
require 'json'

describe CardConnect::Service::Authorization do
  before do
    @connection = CardConnect::Connection.new.connection do |stubs|
      stubs.put(@service.path) { [200, {}, valid_auth_response] }
    end
    @service = CardConnect::Service::Authorization.new(@connection)
  end

  after do
    @service = nil
  end

  it 'must have the right path' do
    @service.path.must_equal '/cardconnect/rest/auth'
  end

  describe '#build_request' do
    before do
      @valid_params = valid_auth_request
    end

    after do
      @valid_params = nil
    end

    it 'uses the default merchant id if it is not passed in' do
      @service.build_request(@valid_params.reject! { |k, _| k == 'merchid' })
      @service.request.merchid.must_equal 'merchant123'
    end

    it 'creates an Authorization request object with the right params' do
      @service.build_request(@valid_params)
      @service.request.must_be_kind_of CardConnect::Service::AuthorizationRequest
      @service.request.merchid.must_equal '000000927996'
      @service.request.account.must_equal '4111111111111111'
      @service.request.expiry.must_equal '1212'
      @service.request.amount.must_equal '0'
      @service.request.currency.must_equal 'USD'
    end
  end

  describe '#submit' do
    it 'raises an error when there is no request' do
      @service.request.nil?.must_equal true
      proc { @service.submit }.must_raise CardConnect::Error
    end

    it 'creates a response when a valid request is processed' do
      @service.build_request(valid_auth_request)
      @service.submit
      @service.response.must_be_kind_of CardConnect::Service::AuthorizationResponse
    end

    it 'parses the json response body sent by the api' do
      connection = CardConnect::Connection.new.connection do |stubs|
        stubs.put('/cardconnect/rest/auth') do
          [200, { 'Content-Type' => 'application/json' }, JSON.generate(valid_auth_response)]
        end
      end

      service = CardConnect::Service::Authorization.new(connection)
      service.build_request(valid_auth_request)
      service.submit

      service.response.body.must_equal symbolize_keys(valid_auth_response)
      service.response.must_be :success?
    end

    it 'returns nil when the api responds with not found' do
      not_found = [404, { 'Content-Type' => 'application/json' }, '{"resptext":"Not found"}']

      connection = CardConnect::Connection.new.connection do |stubs|
        stubs.put('/cardconnect/rest/auth') { not_found }
      end

      service = CardConnect::Service::Authorization.new(connection)
      service.build_request(valid_auth_request)

      out, err = capture_io { service.submit.must_be_nil }

      out.must_be_empty
      err.must_include '404'
      err.must_include '/cardconnect/rest/auth'
      service.response.must_be_nil
    end

    it 'writes the message even when warnings are disabled' do
      not_found = [404, { 'Content-Type' => 'application/json' }, '{"resptext":"Not found"}']

      connection = CardConnect::Connection.new.connection do |stubs|
        stubs.put('/cardconnect/rest/auth') { not_found }
      end

      service = CardConnect::Service::Authorization.new(connection)
      service.build_request(valid_auth_request)

      verbose = $VERBOSE
      begin
        $VERBOSE = nil
        out, err = capture_io { service.submit.must_be_nil }
      ensure
        $VERBOSE = verbose
      end

      out.must_be_empty
      err.must_include '404'
      err.must_include '/cardconnect/rest/auth'
    end

    it 'raises the client error when the api rejects the credentials' do
      unauthorized = [401, { 'Content-Type' => 'application/json' }, '{"resptext":"Unauthorized"}']

      connection = CardConnect::Connection.new.connection do |stubs|
        stubs.put('/cardconnect/rest/auth') { unauthorized }
      end

      service = CardConnect::Service::Authorization.new(connection)
      service.build_request(valid_auth_request)

      proc { service.submit }.must_raise Faraday::UnauthorizedError
      service.response.must_be_nil
    end

    it 'raises the server error when the api fails' do
      server_error = [500, { 'Content-Type' => 'application/json' }, '{"resptext":"Internal server error"}']

      connection = CardConnect::Connection.new.connection do |stubs|
        stubs.put('/cardconnect/rest/auth') { server_error }
      end

      service = CardConnect::Service::Authorization.new(connection)
      service.build_request(valid_auth_request)

      proc { service.submit }.must_raise Faraday::ServerError
      service.response.must_be_nil
    end
  end
end
