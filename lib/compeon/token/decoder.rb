# frozen_string_literal: true

require 'jwt'

module Compeon
  module Token
    class DecodeError < StandardError; end

    class Decoder
      def initialize(encoded_token:, public_key:, token_klass:)
        @encoded_token = encoded_token
        @public_key = public_key
        @token_klass = token_klass
      end

      def decode
        raise DecodeError if decoded_token[:knd] != token_klass.kind

        token = token_klass.new(**decoded_token_attributes)
        token.claims = decoded_token_claims
        token
      end

      private

      attr_reader :encoded_token, :public_key, :token_klass

      def decoded_token
        @decoded_token ||= JWT.decode(
          encoded_token,
          public_key,
          true,
          algorithm: Compeon::Token::JWT_ALGORITHM
        )[0].transform_keys(&:to_sym)
      rescue JWT::DecodeError
        raise DecodeError
      end

      def decoded_token_attributes
        decoded_token.slice(*token_klass.token_attributes).to_h do |attribute, value|
          key = token_klass.attributes_mapping.key(attribute)
          [key, value]
        end
      end

      def decoded_token_claims
        {}.tap do |claims|
          decoded_token.slice(*claim_attributes).each do |claim, value|
            claims[claim] = value
          end
        end
      end

      def claim_attributes
        decoded_token.keys - token_klass.token_attributes - [:knd]
      end
    end
  end
end
