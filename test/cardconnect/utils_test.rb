require 'test_helper'

describe CardConnect::Utils do
  before do
    @subject = Class.new do
      include CardConnect::Utils

      attr_accessor :merchid, :amount
    end.new
  end

  after do
    @subject = nil
  end

  describe '#set_attributes' do
    it 'should assign the attributes of a hash with string keys' do
      @subject.set_attributes({ 'merchid' => 'merchant123', 'amount' => '100' }, [:merchid, :amount])

      @subject.merchid.must_equal 'merchant123'
      @subject.amount.must_equal '100'
    end

    it 'should use the first element when given an array' do
      @subject.set_attributes([{ 'merchid' => 'merchant123' }, { 'merchid' => 'other' }], [:merchid])

      @subject.merchid.must_equal 'merchant123'
    end

    it 'should leave the attributes untouched when there are no attributes' do
      @subject.set_attributes({}, [:merchid])

      @subject.merchid.must_be_nil
    end
  end

  describe '#symbolize_keys' do
    it 'should symbolize the keys of the hash' do
      @subject.symbolize_keys('merchid' => 'merchant123').must_equal(merchid: 'merchant123')
    end
  end
end
