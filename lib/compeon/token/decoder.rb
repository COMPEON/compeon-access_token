# frozen_string_literal: true

require 'jwt'

module Compeon
  module Token
    class DecodeError < StandardError; end

    class Decoder
      def initialize(claim_verifications: {}, encoded_token:, key:, token_klass:)
        @claim_verifications = claim_verifications
        @encoded_token = encoded_token
        @key = key
        @token_klass = token_klass
      end

      def decode
        raise DecodeError if decoded_token[:knd] != token_klass.kind

        attributes = decoded_token_attributes
        attributes.delete(:knd)

        token_klass.new(**attributes)
      end

      private

      attr_reader :claim_verifications, :encoded_token, :key, :token_klass

      def decoded_token
        @decoded_token ||= JWT.decode(
          encoded_token,
          key,
          true,
          algorithm: token_klass.jwt_algorithm,
          **compiled_claim_verifications
        )[0].transform_keys(&:to_sym)
      rescue JWT::DecodeError
        raise DecodeError
      end

      def decoded_token_attributes
        attributes_mapping = token_klass.attributes_mapping
        registered_claims_mapping = token_klass.registered_claims_mapping

        decoded_token.transform_keys do |attribute|
          attributes_mapping.key(attribute) ||
            registered_claims_mapping.key(attribute) ||
            attribute
        end
      end

      def compiled_claim_verifications
        {}.tap do |verifications|
          %i[aud iss sub].each do |claim|
            next unless claim_verifications[claim]

            verifications[claim] = claim_verifications[claim]
            verifications[:"verify_#{claim}"] = true
          end

          verifications[:verify_iat] = true if claim_verifications[:iat]
        end
      end
    end
  end
end
