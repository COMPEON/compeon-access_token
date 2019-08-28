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
        JWT.encode(
          {
            **attributes,
            **token.registered_claims,
            knd: token.class.kind
          },
          key,
          token.class.jwt_algorithm
        )
      rescue JWT::EncodeError
        raise EncodeError
      end

      private

      attr_reader :token, :key

      def attributes
        token.class.attributes_mapping.invert.transform_values do |attribute|
          token.public_send(attribute)
        end
      end
    end
  end
end
