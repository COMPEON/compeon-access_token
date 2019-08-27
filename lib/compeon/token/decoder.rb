# frozen_string_literal: true

require 'jwt'

module Compeon
  module Token
    class DecodeError < StandardError; end

    class Decoder
      def initialize(claim_verifications: {}, encoded_token:, public_key:, token_klass:)
        @claim_verifications = claim_verifications
        @encoded_token = encoded_token
        @public_key = public_key
        @token_klass = token_klass
      end

      def decode
        raise DecodeError if decoded_token[:knd] != token_klass.kind

        token_klass.new(**decoded_token_attributes)
      end

      private

      attr_reader :claim_verifications, :encoded_token, :public_key, :token_klass

      def decoded_token
        @decoded_token ||= JWT.decode(
          encoded_token,
          public_key,
          true,
          algorithm: Compeon::Token::JWT_ALGORITHM,
          **compiled_claim_verifications
        )[0].transform_keys(&:to_sym)
      rescue JWT::DecodeError
        raise DecodeError
      end

      def decoded_token_attributes
        decoded_token.to_h do |attribute, value|
          key = token_klass.attributes_mapping.key(attribute)

          [key || attribute, value]
        end
      end

      def claim_attributes
        decoded_token.keys - token_klass.token_attributes - [:knd]
      end

      def compiled_claim_verifications
        {}.tap do |verifications|
          %i[aud iss sub].each do |claim|
            next unless claim_verifications[claim]

            verifications[claim] = claim_verifications[claim]
            verifications["verify_#{claim}".to_sym] = true
          end

          verifications[:verify_iat] = true if claim_verifications[:iat]
        end
      end
    end
  end
end
