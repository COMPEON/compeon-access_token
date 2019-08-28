# frozen_string_literal: true

require 'test_helper'

class Compeon::Token::EncoderTest < Minitest::Test
  PRIVATE_KEY = OpenSSL::PKey::RSA.new(512)

  class TestToken < Compeon::Token::Base
    self.jwt_algorithm = 'RS256'

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
      super(claims)
      @attribute = attribute
    end
  end

  def test_it_takes_the_algorithm_from_the_token_class
    expires_at = Time.now.to_i + 3600
    token = TestToken.new(attribute: '1 Attribut', expires_at: expires_at)

    jwt_encoder = lambda do |payload, key, algorithm|
      assert_equal({ attr: '1 Attribut', exp: expires_at, knd: 'test' }, payload)
      assert_equal(PRIVATE_KEY, key)
      assert_equal('SELECTED ALGORITHM', algorithm)
    end

    TestToken.stub(:jwt_algorithm, 'SELECTED ALGORITHM') do
      JWT.stub(:encode, jwt_encoder) do
        Compeon::Token::Encoder.new(
          key: PRIVATE_KEY,
          token: token
        ).encode
      end
    end
  end

  def test_with_a_valid_token
    token = TestToken.new(attribute: '1 Attribut')
    token.expires_at = Time.now.to_i + 3600

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
    not_before = current_time - 1200

    token = TestToken.new(
      attribute: '1 Attribut',
      audience: 'audience',
      expires_at: expires_at,
      issued_at: current_time,
      issuer: 'compeon',
      not_before: not_before,
      subject: 'auth'
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
    assert_equal(not_before, decoded_token['nbf'])
    assert_equal('auth', decoded_token['sub'])
  end

  def test_with_an_expiry_time_in_the_past
    token = TestToken.new(attribute: '1 Attribut')
    token.expires_at = Time.now.to_i - 1

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
    token.expires_at = Time.now.to_i + 3600

    assert_raises do
      Compeon::Token::Encoder.new(
        key: PRIVATE_KEY,
        token: token
      ).encode
    end
  end

  def test_with_a_missing_key
    token = TestToken.new(attribute: '1 Attribut')
    token.expires_at = Time.now.to_i + 3600

    assert_raises do
      Compeon::Token::Encoder.new(
        key: nil,
        token: token
      ).encode
    end
  end
end
