# frozen_string_literal: true

module ActiveInteraction
  # Validates inputs using filters.
  #
  # @private
  module Validation
    class << self
      # @param context [Base]
      # @param filters [Hash{Symbol => Filter}]
      # @param inputs [ActiveInteraction::Inputs]
      def validate(context, filters, inputs)
        filters.each_with_object([]) do |(name, filter), errors|
          input = filter.process(inputs[name], context)

          if input.error
            new_error = error_to_validation_error(input.error, filter)
            errors << new_error if new_error
          end
        end
      end

      private

      def type(filter)
        I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}")
      end

      def error_to_validation_error(error, filter)
        case error
        when InvalidNestedValueError
          [
            filter.name,
            :invalid_nested,
            { name: error.filter_name.inspect, value: error.input_value.inspect }
          ]
        when InvalidValueError
          [filter.name, :invalid_type, { type: type(filter) }]
        when MissingValueError
          [filter.name, :missing]
        else
          raise "invalid error #{error}"
        end
      end
    end
  end
end
