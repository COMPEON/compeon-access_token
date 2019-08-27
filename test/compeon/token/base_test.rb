# frozen_string_literal: true

require 'test_helper'

class Compeon::Token::BaseTest < Minitest::Test
  class TestToken < Compeon::Token::Base
    class << self
      def attributes_mapping
        { attribute: :attr }.freeze
      end

      def kind
        'test'
      end
    end

    attr_accessor :attribute

    def initialize(attribute:)
      @attribute = attribute
    end
  end

  def token
    @token ||= begin
      token = TestToken.new(attribute: 'test attribute')
      token.claims[:exp] = Time.now.to_i + 3600
      token
    end
  end

  def test_with_a_valid_token
    assert(token.valid?)
  end

  def test_with_a_missing_expiry_time
    token.claims[:exp] = nil

    assert_equal(false, token.valid?)
  end

  def test_with_an_expiry_time_in_the_past
    token.claims[:exp] = Time.now.to_i - 1

    assert_equal(false, token.valid?)
  end

  def test_with_a_missing_attribute
    token.attribute = nil

    assert_equal(false, token.valid?)
  end

  def test_decode
    mock = Minitest::Mock.new
    mock.expect(:decode, 'decoded token')

    decoder = lambda { |claim_verifications:, encoded_token:, public_key:, token_klass:|
      assert_equal('claims', claim_verifications)
      assert_equal('encoded token', encoded_token)
      assert_equal('public key', public_key)
      assert_equal(TestToken, token_klass)
      mock
    }

    Compeon::Token::Decoder.stub(:new, decoder) do
      token = TestToken.decode(
        claim_verifications: 'claims',
        encoded_token: 'encoded token',
        public_key: 'public key'
      )

      assert_equal('decoded token', token)
    end

    assert_mock(mock)
  end

  def test_encode
    test_token = TestToken.new(attribute: 'test attribute')

    mock = Minitest::Mock.new
    mock.expect(:encode, 'encoded token')

    encoder = lambda { |private_key:, token:|
      assert_equal('private key', private_key)
      assert_equal(test_token, token)
      mock
    }

    Compeon::Token::Encoder.stub(:new, encoder) do
      encoded_token = test_token.encode(
        private_key: 'private key'
      ).encode

      assert_equal('encoded token', encoded_token)
    end

    assert_mock(mock)
  end
end
