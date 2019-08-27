# frozen_string_literal: true

module Compeon
  module Token
    class Access < Base
      ATTRIBUTES_MAPPING = {
        client_id: :cid,
        role: :role,
        user_id: :uid
      }.freeze

      KIND = 'access'

      attr_accessor :client_id, :role, :user_id

      def initialize(client_id:, role:, user_id:)
        @client_id = client_id
        @role = role
        @user_id = user_id
      end
    end
  end
end
