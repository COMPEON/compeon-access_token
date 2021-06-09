# frozen_string_literal: true

module Compeon
  module Token
    class Base
      attr_accessor :audience, :expires_at, :issued_at, :issuer, :not_before, :subject

      class << self
        def attributes
          @attributes ||= attributes_mapping.keys.freeze
        end

        def attributes_mapping
          required_attributes_mapping.merge(optional_attributes_mapping).freeze
        end

        def required_attributes
          @required_attributes ||= required_attributes_mapping.keys.freeze
        end

        def optional_attributes
          @optional_attributes ||= optional_attributes_mapping.keys.freeze
        end

        def registered_claims_mapping
          {
            audience: :aud,
            expires_at: :exp,
            issued_at: :iat,
            issuer: :iss,
            not_before: :nbf,
            subject: :sub
          }.freeze
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

      def initialize(audience: nil, expires_at: nil, issued_at: nil, issuer: nil, not_before: nil, subject: nil)
        @audience = audience
        @expires_at = expires_at
        @issued_at = issued_at
        @issuer = issuer
        @not_before = not_before
        @subject = subject
      end

      def encode(key:)
        Compeon::Token::Encoder.new(
          key: key,
          token: self
        ).encode
      end

      def registered_claims
        self
          .class
          .registered_claims_mapping
          .invert
          .transform_values { |claim| public_send(claim) }
          .compact
      end

      def valid?
        expires_at_valid? && attributes_valid?
      end

      def expires_at_valid?
        !expires_at.nil? && expires_at > Time.now.to_i
      end

      def attributes_valid?
        self.class.required_attributes.none? { |accessor| public_send(accessor).nil? }
      end
    end
  end
end
