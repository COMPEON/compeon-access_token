# frozen_string_literal: true

require 'jwt'

module Compeon
  module Token
    class EncodeError < StandardError; end

    class Encoder
      def initialize(private_key:, token:)
        @token = token
        @private_key = private_key

        raise 'No private key given.' if @private_key.nil?
        raise 'Token is invalid.' unless @token.valid?
      end

      def encode
        raw_token = build_raw_token

        JWT.encode(
          raw_token,
          private_key,
          Compeon::Token::JWT_ALGORITHM
        )
      rescue JWT::EncodeError
        raise EncodeError
      end

      private

      attr_reader :token, :private_key

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
