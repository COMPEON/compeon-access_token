# frozen_string_literal: true

module Compeon
  module Token
    module Base
      def self.attributes(**attributes_mapping)
        attributes = attributes_mapping.keys.freeze
        token_attributes = attributes_mapping.values.freeze
        token_attributes_mapping = {}.tap do |token_attrs_mapping|
          attributes_mapping.each { |key, value| token_attrs_mapping[value] = key }
        end

        accessors = attributes.map { |attr| ":#{attr}" }.join(', ')
        init_args = attributes.map { |attr| "#{attr}:" }.join(', ')
        init_instance_vars = attributes.map { |attr| "@#{attr} = #{attr}; " }.join

        Module.new do
          def self.name
            'Compeon::Token::Base'
          end

          class_eval <<~RUBY
            module ClassMethods
              def attributes
                #{attributes}.freeze
              end

              def token_attributes
                #{token_attributes}
              end

              def attributes_mapping
                #{attributes_mapping}.freeze
              end

              def token_attributes_mapping
                #{token_attributes_mapping}.freeze
              end
            end

            def self.included(base)
              base.extend(ClassMethods)
            end

            attr_accessor #{accessors}
            attr_accessor :claims

            def initialize #{init_args}
              @claims = {}
              #{init_instance_vars}
            end

            def valid?
              expires_at_valid? && attributes_valid?
            end

            def expires_at_valid?
              expires_at = claims[:exp]

              expires_at.is_a?(Numeric) && expires_at > Time.now.to_i
            end

            def attributes_valid?
              [#{accessors}].none? { |accessor| public_send(accessor).nil? }
            end
          RUBY
        end
      end
    end
  end
end
