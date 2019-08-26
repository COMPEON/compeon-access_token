# frozen_string_literal: true

require 'test_helper'

class Compeon::Token::DecoderTest < Minitest::Test
  PRIVATE_KEY = OpenSSL::PKey::RSA.new(512)

  class TestToken
    include Compeon::Token::Base.attributes(attribute: :attr)

    KIND = 'test'
  end

  def test_with_a_valid_token
    encoded_token = JWT.encode({ attr: 'Ein Attribut', knd: 'test' }, PRIVATE_KEY, 'RS256')

    decoded_token = Compeon::Token::Decoder.new(
      encoded_token: encoded_token,
      public_key: PRIVATE_KEY.public_key,
      token_klass: TestToken
    ).decode

    assert_equal(TestToken, decoded_token.class)
    assert_equal('Ein Attribut', decoded_token.attribute)
  end

  def test_with_additional_claims
    expires_at = Time.now.to_i + 3600
    encoded_token = JWT.encode(
      {
        attr: 'Ein Attribut',
        knd: 'test',
        exp: expires_at,
        iss: 'compeon',
        sub: 'auth'
      },
      PRIVATE_KEY,
      'RS256'
    )

    decoded_token = Compeon::Token::Decoder.new(
      encoded_token: encoded_token,
      public_key: PRIVATE_KEY.public_key,
      token_klass: TestToken
    ).decode

    assert_equal(TestToken, decoded_token.class)
    assert_equal('Ein Attribut', decoded_token.attribute)
    assert_equal(expires_at, decoded_token.claims[:exp])
    assert_equal('compeon', decoded_token.claims[:iss])
    assert_equal('auth', decoded_token.claims[:sub])
  end

  def test_with_a_token_of_wrong_kind
    encoded_token = JWT.encode({ attr: 'Ein Attribut', knd: 'not_test' }, PRIVATE_KEY, 'RS256')

    assert_raises Compeon::Token::DecodeError do
      Compeon::Token::Decoder.new(
        encoded_token: encoded_token,
        public_key: PRIVATE_KEY.public_key,
        token_klass: TestToken
      ).decode
    end
  end

  def test_with_an_expired_token
    encoded_token = JWT.encode({ attr: 'Ein Attribut', exp: 0, knd: 'test' }, PRIVATE_KEY, 'RS256')

    assert_raises Compeon::Token::DecodeError do
      Compeon::Token::Decoder.new(
        encoded_token: encoded_token,
        public_key: PRIVATE_KEY.public_key,
        token_klass: TestToken
      ).decode
    end
  end
end
