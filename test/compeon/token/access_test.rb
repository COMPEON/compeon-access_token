# frozen_string_literal: true

require 'test_helper'

class Compeon::Token::AccessTest < Minitest::Test
  def test_inherits_from_test
    assert(Compeon::Token::Access.ancestors.include?(Compeon::Token::Base))
  end

  def test_kind
    assert_equal('access', Compeon::Token::Access.kind)
  end

  def test_attributes
    assert_equal(%i[client_id role user_id session_id], Compeon::Token::Access.attributes)
  end

  def test_attributes_mapping
    assert_equal(
      {
        client_id: :cid,
        role: :role,
        user_id: :uid,
        session_id: :sid
      },
      Compeon::Token::Access.attributes_mapping
    )
  end

  def test_constructor
    Compeon::Token::Access.new(
      client_id: 'client id',
      role: 'role',
      user_id: 'user id',
      session_id: 'session id'
    )
  end


  def test_session_id_is_optional
    token = Compeon::Token::Access.new(
      client_id: 'client id',
      role: 'role',
      user_id: 'user id'
    )

    assert_equal(nil, token.session_id)
  end

  def test_attr_accessors
    token = Compeon::Token::Access.new(
      client_id: 'client id',
      role: 'role',
      user_id: 'user id'
    )

    assert_equal('client id', token.client_id)
    assert_equal('role', token.role)
    assert_equal('user id', token.user_id)
    assert(true, token.respond_to?(:client_id=))
    assert(true, token.respond_to?(:role=))
    assert(true, token.respond_to?(:user_id=))
    assert(true, token.respond_to?(:session_id=))
  end
end
