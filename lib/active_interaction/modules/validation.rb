# frozen_string_literal: true

module ActiveInteraction
  # Validates inputs using filters.
  #
  # @private
  module Validation
    class << self
      # @param context [Base]
      # @param filters [Hash{Symbol => Filter}]
      # @param inputs [Inputs]
      def validate(context, filters, inputs)
        filters.each_with_object([]) do |(name, filter), errors|
          input = filter.process(inputs[name], context)

          input.errors.each do |error|
            new_error = error_to_validation_error(error, filter)
            errors << new_error if new_error
          end
        end
      end

      private

      def error_to_validation_error(error, filter)
        if error.is_a?(Filter::Error)
          [error.name, error.type, error.options]
        else
          case error
          when InvalidNestedValueError
            [
              filter.name,
              :invalid_nested,
              { name: error.filter_name.inspect, value: error.input_value.inspect }
            ]
          else
            raise "invalid error #{error}"
          end
        end
      end
    end
  end
end
