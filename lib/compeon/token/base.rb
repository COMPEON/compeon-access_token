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

        def token_attributes_mapping
          @token_attributes_mapping = {}.tap do |token_attrs_mapping|
            attributes_mapping.each { |key, value| token_attrs_mapping[value] = key }
          end
        end
      end

      def claims
        @claims ||= {}
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
