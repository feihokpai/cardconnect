require 'cardconnect'

require 'minitest/autorun'
require 'minitest/pride'

require 'api_request_stubs'
require 'api_response_stubs'

include CardConnect::Utils

CardConnect.configure do |config|
  config.merchant_id = 'merchant123'
  config.api_username = 'test'
  config.api_password = 'testpass'
  config.endpoint = 'https://test.host'
end

# Swap the real connection's adapter for Faraday's test adapter, keeping the
# production middleware stack under test.
module StubbedConnection
  def connection(&block)
    @connection ||= super.tap do |connection|
      connection.builder.adapter(:test) { |stubs| block.call(stubs) } if block
    end
  end
end

CardConnect::Connection.prepend(StubbedConnection)
