require 'test_helper'

describe CardConnect do
  it 'must respond to configure' do
    CardConnect.must_respond_to :configure
  end

  describe 'configuration' do
    it 'must return instance of Configuration' do
      CardConnect.configuration.must_be_kind_of CardConnect::Configuration
    end
  end

  describe 'connection' do
    it 'must return a Faraday connection' do
      CardConnect.connection.must_be_kind_of Faraday::Connection
    end

    it 'must reuse the same connection' do
      CardConnect.connection.must_be_same_as(CardConnect.connection)
    end
  end
end
