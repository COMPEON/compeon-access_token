# frozen_string_literal: true

module Compeon
  module Token
    class Base
      attr_writer :claims

      class << self
        def attributes
          @attributes ||= attributes_mapping.keys.freeze
        end

        def token_attributes
          @token_attributes ||= attributes_mapping.values.freeze
        end

        def decode(claim_verifications: {}, encoded_token:, public_key:)
          Compeon::Token::Decoder.new(
            claim_verifications: claim_verifications,
            encoded_token: encoded_token,
            public_key: public_key,
            token_klass: self
          ).decode
        end
      end

      def claims
        @claims ||= {}
      end

      def encode(private_key:)
        Compeon::Token::Encoder.new(
          private_key: private_key,
          token: self
        ).encode
      end

      def valid?
        expires_at_valid? && attributes_valid?
      end

      def expires_at_valid?
        expires_at = claims[:exp]

        expires_at.is_a?(Numeric) && expires_at > Time.now.to_i
      end

      def attributes_valid?
        self.class.attributes.none? { |accessor| public_send(accessor).nil? }
      end
    end
  end
end
