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

    def initialize(attribute:, **claims)
      super(**claims)
      @attribute = attribute
    end
  end

  def token
    @token ||= begin
      TestToken.new(
        attribute: 'test attribute',
        exp: Time.now.to_i + 3600
      )
    end
  end

  def test_with_a_valid_token
    assert(token.valid?)
  end

  def test_with_a_missing_expiry_time
    token.exp = nil

    assert_equal(false, token.valid?)
  end

  def test_with_an_expiry_time_in_the_past
    token.exp = Time.now.to_i - 1

    assert_equal(false, token.valid?)
  end

  def test_with_a_missing_attribute
    token.attribute = nil

    assert_equal(false, token.valid?)
  end

  def test_attr_accessors
    current_time = Time.now.to_i
    expires_at = current_time + 3600

    token = TestToken.new(
      attribute: '1 attribut',
      aud: 'audience',
      exp: expires_at,
      iat: current_time,
      iss: 'compeon',
      sub: 'auth'
    )

    assert_equal('audience', token.aud)
    assert_equal(expires_at, token.exp)
    assert_equal(current_time, token.iat)
    assert_equal('compeon', token.iss)
    assert_equal('auth', token.sub)

    assert(true, token.respond_to?(:aud=))
    assert(true, token.respond_to?(:exp=))
    assert(true, token.respond_to?(:iat=))
    assert(true, token.respond_to?(:iss=))
    assert(true, token.respond_to?(:sub=))
  end

  def test_decode
    mock = Minitest::Mock.new
    mock.expect(:decode, 'decoded token')

    decoder = lambda { |claim_verifications:, encoded_token:, key:, token_klass:|
      assert_equal('claims', claim_verifications)
      assert_equal('encoded token', encoded_token)
      assert_equal('public key', key)
      assert_equal(TestToken, token_klass)
      mock
    }

    Compeon::Token::Decoder.stub(:new, decoder) do
      token = TestToken.decode(
        claim_verifications: 'claims',
        encoded_token: 'encoded token',
        key: 'public key'
      )

      assert_equal('decoded token', token)
    end

    assert_mock(mock)
  end

  def test_encode
    test_token = TestToken.new(attribute: 'test attribute')

    mock = Minitest::Mock.new
    mock.expect(:encode, 'encoded token')

    encoder = lambda { |key:, token:|
      assert_equal('private key', key)
      assert_equal(test_token, token)
      mock
    }

    Compeon::Token::Encoder.stub(:new, encoder) do
      encoded_token = test_token.encode(
        key: 'private key'
      ).encode

      assert_equal('encoded token', encoded_token)
    end

    assert_mock(mock)
  end
end
