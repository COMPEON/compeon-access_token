# frozen_string_literal: true

require 'test_helper'

class Compeon::Token::AuthorizationTest < Minitest::Test
  def test_inherits_from_test
    assert(Compeon::Token::Authorization.ancestors.include?(Compeon::Token::Base))
  end

  def test_kind
    assert_equal('auth', Compeon::Token::Authorization.kind)
  end

  def test_attributes
    assert_equal(%i[client_id redirect_uri user_id], Compeon::Token::Authorization.attributes)
  end

  def test_attributes_mapping
    assert_equal(
      {
        client_id: :cid,
        redirect_uri: :uri,
        user_id: :uid
      },
      Compeon::Token::Authorization.attributes_mapping
    )
  end

  def test_constructor
    Compeon::Token::Authorization.new(
      client_id: 'client id',
      redirect_uri: 'redirect uri',
      user_id: 'user id'
    )
  end

  def test_attr_accessors
    token = Compeon::Token::Authorization.new(
      client_id: 'client id',
      redirect_uri: 'redirect uri',
      user_id: 'user id'
    )

    assert_equal('client id', token.client_id)
    assert_equal('redirect uri', token.redirect_uri)
    assert_equal('user id', token.user_id)
    assert(true, token.respond_to?(:client_id=))
    assert(true, token.respond_to?(:redirect_uri=))
    assert(true, token.respond_to?(:user_id=))
  end
end
