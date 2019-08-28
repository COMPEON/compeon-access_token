# frozen_string_literal: true

module Compeon
  module Token
    class Base
      attr_accessor :aud, :exp, :iat, :iss, :sub

      class << self
        def attributes
          @attributes ||= attributes_mapping.keys.freeze
        end

        def decode(claim_verifications: {}, encoded_token:, key:)
          Compeon::Token::Decoder.new(
            claim_verifications: claim_verifications,
            encoded_token: encoded_token,
            key: key,
            token_klass: self
          ).decode
        end
      end

      def initialize(**claims)
        @aud = claims[:aud]
        @exp = claims[:exp]
        @iat = claims[:iat]
        @iss = claims[:iss]
        @sub = claims[:sub]
      end

      def encode(key:)
        Compeon::Token::Encoder.new(
          key: key,
          token: self
        ).encode
      end

      def reserved_claims
        {
          aud: aud,
          exp: exp,
          iat: iat,
          iss: iss,
          sub: sub
        }
      end

      def valid?
        expires_at_valid? && attributes_valid?
      end

      def expires_at_valid?
        exp.is_a?(Numeric) && exp > Time.now.to_i
      end

      def attributes_valid?
        self.class.attributes.none? { |accessor| public_send(accessor).nil? }
      end
    end
  end
end
