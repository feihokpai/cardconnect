require 'test_helper'
require 'json'

describe CardConnect::Connection do
  before do
    @connection = CardConnect::Connection.new.connection
  end

  after do
    @connection = nil
  end

  describe '#connection' do
    it 'must have user agent in the headers' do
      @connection.headers['User-Agent'].must_equal "CardConnectRubyGem/#{CardConnect::VERSION}"
    end

    it 'must have a URL that matches the configured endpoint' do
      @connection.url_prefix.host.must_equal URI.parse(CardConnect.configuration.endpoint).host
      @connection.url_prefix.scheme.must_equal 'https'
    end

    describe 'Faraday handlers' do
      it 'must have a handler for basic authentication first' do
        @connection.builder.handlers.first.must_be :===, Faraday::Request::Authorization
      end

      it 'must have a handler for encoding the request as json second' do
        @connection.builder.handlers[1].must_be :===, Faraday::Request::Json
      end

      it 'must have a handler for parsing the json response third' do
        @connection.builder.handlers[2].must_be :===, Faraday::Response::Json
      end

      it 'has ssl verification on by default' do
        assert(@connection.ssl.verify?)
      end

      it 'has the ability to accept ssl options' do
        config = CardConnect.configuration.dup
        config.connection_options = { ssl: { verify: false } }
        connection = CardConnect::Connection.new(config).connection
        refute(connection.ssl.verify)
      end
    end

    describe 'requests' do
      it 'must send the api credentials as basic authentication' do
        authorization = nil

        connection = CardConnect::Connection.new.connection do |stubs|
          stubs.post('/cardconnect/rest/test') do |env|
            authorization = env.request_headers['Authorization']
            [200, { 'Content-Type' => 'application/json' }, '{}']
          end
        end

        connection.post('/cardconnect/rest/test')

        authorization.must_equal "Basic #{['test:testpass'].pack('m0')}"
      end

      it 'must send the request body encoded as json' do
        request_body = nil
        content_type = nil

        connection = CardConnect::Connection.new.connection do |stubs|
          stubs.post('/cardconnect/rest/test') do |env|
            request_body = env.body
            content_type = env.request_headers['Content-Type']
            [200, { 'Content-Type' => 'application/json' }, '{}']
          end
        end

        connection.post('/cardconnect/rest/test') { |req| req.body = { 'merchid' => 'merchant123' } }

        JSON.parse(request_body).must_equal('merchid' => 'merchant123')
        content_type.must_match(%r{\Aapplication/json})
      end

      it 'must raise an error when the api responds with a server error' do
        connection = CardConnect::Connection.new.connection do |stubs|
          stubs.get('/cardconnect/rest/test') { [500, {}, 'internal server error'] }
        end

        proc { connection.get('/cardconnect/rest/test') }.must_raise Faraday::ServerError
      end
    end
  end

  describe '#ping_server' do
    it 'must return the error when the endpoint is not found' do
      stubbed = CardConnect::Connection.new.connection do |stubs|
        stubs.get('/cardconnect/rest/') { [404, { 'Content-Type' => 'application/json' }, '{}'] }
      end

      connection = CardConnect::Connection.new
      connection.stub(:connection, stubbed) do
        connection.ping_server.must_be_kind_of Faraday::ResourceNotFound
      end
    end

    it 'must return the error when the credentials are rejected' do
      stubbed = CardConnect::Connection.new.connection do |stubs|
        stubs.get('/cardconnect/rest/') { [401, { 'Content-Type' => 'application/json' }, '{}'] }
      end

      connection = CardConnect::Connection.new
      connection.stub(:connection, stubbed) do
        connection.ping_server.must_be_kind_of Faraday::UnauthorizedError
      end
    end
  end
end
