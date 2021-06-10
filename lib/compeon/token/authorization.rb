# frozen_string_literal: true

module Compeon
  module Token
    class Authorization < Base
      class << self
        def required_attributes_mapping
          {
            client_id: :cid,
            redirect_uri: :uri,
            user_id: :uid
          }.freeze
        end

        def optional_attributes_mapping
          { session_id: :sid }.freeze
        end

        def jwt_algorithm
          'RS256'
        end

        def kind
          'auth'
        end
      end

      attr_accessor :client_id, :redirect_uri, :user_id, :session_id

      def initialize(client_id:, redirect_uri:, user_id:, session_id: nil, **claims)
        super(claims)
        @client_id = client_id
        @redirect_uri = redirect_uri
        @user_id = user_id
        @session_id = session_id
      end
    end
  end
end
