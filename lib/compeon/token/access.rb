# frozen_string_literal: true

module Compeon
  module Token
    class Access
      include Compeon::Token::Base.attributes(
        client_id: :cid,
        role: :role,
        user_id: :uid
      )

      KIND = 'access'
    end
  end
end
