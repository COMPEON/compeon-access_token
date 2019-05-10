# frozen_string_literal: true

require 'compeon/access_token/version'

require 'jwt'
require 'open-uri'

module Compeon
  class AccessToken
    class ParseError < RuntimeError; end

    def initialize(role:, user_id:, kind:, client_id:, token:)
      @role = role
      @user_id = user_id
      @kind = kind
      @client_id = client_id
      @token = token
    end

    attr_reader :role, :user_id, :kind, :client_id, :token

    class << self
      attr_writer :environment

      def environment
        @environment ||
          ENV['ENVIRONMENT'] ||
          raise("`#{self}.environment` or `ENV['ENVIRONMENT']` must be set")
      end

      def parse(token)
        data, _header = JWT.decode(token, public_key, false, algorithm: 'RS256')

        role = data.fetch('role')
        user_id = data.fetch('uid')
        kind = data.fetch('knd')
        client_id = data.fetch('cid')

        new(role: role, user_id: user_id, kind: kind, client_id: client_id, token: token)
      rescue JWT::DecodeError
        throw ParseError
      end

      def public_key
        @public_key ||= OpenSSL::PKey::RSA.new(public_key_string)
      end

      def public_key_string=(value)
        @public_key = nil
        @public_key_string = value
      end

      def public_key_string
        @public_key_string ||= begin
          env_subdomain = environment != 'production' ? ".#{environment}" : nil
          URI.parse("https://login#{env_subdomain}.compeon.de/public-key").read
        end
      end
    end
  end
end
