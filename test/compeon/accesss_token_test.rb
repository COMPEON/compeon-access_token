require 'test_helper'

class Compeon::AccessTokenTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Compeon::AccessToken::VERSION
  end
end
