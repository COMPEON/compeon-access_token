# frozen_string_literal: true

require 'test_helper'

class Compeon::Token::EncoderTest < Minitest::Test
  PRIVATE_KEY = OpenSSL::PKey::RSA.new(512)

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

  def test_with_a_valid_token
    token = TestToken.new(attribute: '1 Attribut')
    token.exp = Time.now.to_i + 3600

    encoded_token = Compeon::Token::Encoder.new(
      key: PRIVATE_KEY,
      token: token
    ).encode

    assert_equal(String, encoded_token.class)

    decoded_token = JWT.decode(
      encoded_token,
      PRIVATE_KEY.public_key,
      true,
      algorithm: 'RS256'
    )[0]

    assert_equal('1 Attribut', decoded_token['attr'])
    assert_equal('test', decoded_token['knd'])
  end

  def test_with_additional_claims
    current_time = Time.now.to_i
    expires_at = current_time + 3600
    token = TestToken.new(
      attribute: '1 Attribut',
      aud: 'audience',
      exp: expires_at,
      iat: current_time,
      iss: 'compeon',
      sub: 'auth'
    )

    encoded_token = Compeon::Token::Encoder.new(
      key: PRIVATE_KEY,
      token: token
    ).encode

    assert_equal(String, encoded_token.class)

    decoded_token = JWT.decode(
      encoded_token,
      PRIVATE_KEY.public_key,
      true,
      algorithm: 'RS256'
    )[0]

    assert_equal('audience', decoded_token['aud'])
    assert_equal(expires_at, decoded_token['exp'])
    assert_equal(current_time, decoded_token['iat'])
    assert_equal('compeon', decoded_token['iss'])
    assert_equal('auth', decoded_token['sub'])
  end

  def test_with_an_expiry_time_in_the_past
    token = TestToken.new(attribute: '1 Attribut')
    token.exp = Time.now.to_i - 1

    assert_raises do
      Compeon::Token::Encoder.new(
        key: PRIVATE_KEY,
        token: token
      ).encode
    end
  end

  def test_without_an_exp_claim
    token = TestToken.new(attribute: '1 Attribut')

    assert_raises do
      Compeon::Token::Encoder.new(
        key: PRIVATE_KEY,
        token: token
      ).encode
    end
  end

  def test_with_a_missing_attribute
    token = TestToken.new(attribute: nil)
    token.exp = Time.now.to_i + 3600

    assert_raises do
      Compeon::Token::Encoder.new(
        key: PRIVATE_KEY,
        token: token
      ).encode
    end
  end

  def test_with_a_missing_key
    token = TestToken.new(attribute: '1 Attribut')
    token.exp = Time.now.to_i + 3600

    assert_raises do
      Compeon::Token::Encoder.new(
        key: nil,
        token: token
      ).encode
    end
  end
end
