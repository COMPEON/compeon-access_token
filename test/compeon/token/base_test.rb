# frozen_string_literal: true

require 'test_helper'

class Compeon::Token::BaseTest < Minitest::Test
  class TestToken
    include Compeon::Token::Base.attributes(attribute: :attr)
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
end