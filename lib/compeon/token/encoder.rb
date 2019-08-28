# frozen_string_literal: true

require 'jwt'

module Compeon
  module Token
    class EncodeError < StandardError; end

    class Encoder
      def initialize(key:, token:)
        @token = token
        @key = key

        raise 'No key given.' if @key.nil?
        raise 'Token is invalid.' unless @token.valid?
      end

      def encode
        raw_token = build_raw_token

        JWT.encode(
          raw_token,
          key,
          token.class.jwt_algorithm
        )
      rescue JWT::EncodeError
        raise EncodeError
      end

      private

      attr_reader :token, :key

      def build_raw_token
        {}.tap do |raw_token|
          token.class.attributes_mapping.each do |attribute, token_attribute|
            raw_token[token_attribute] = token.public_send(attribute)
          end
        end.merge(token.reserved_claims, knd: token.class.kind)
      end
    end
  end
end
