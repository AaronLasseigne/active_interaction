# frozen_string_literal: true

module ActiveInteraction
  # Validates inputs using filters.
  #
  # @private
  module Validation
    class << self
      # @param context [Base]
      # @param filters [Hash{Symbol => Filter}]
      # @param inputs [Hash{Symbol => Object}]
      def validate(context, filters, inputs)
        filters.each_with_object([]) do |(name, filter), errors|
          begin
            filter.clean(inputs[name], context)
          rescue NoDefaultError
            nil
          rescue InvalidNestedValueError,
                 InvalidValueError, MissingValueError => e
            errors << error_args(filter, e)
          end
        end
      end

      private

      def error_args(filter, error)
        case error
        when InvalidNestedValueError
          [filter.name, :invalid_nested,
           name: error.filter_name.inspect, value: error.input_value.inspect]
        when InvalidValueError
          [filter.name, :invalid_type, type: type(filter)]
        when MissingValueError
          [filter.name, :missing]
        end
      end

      # @param filter [Filter]
      def type(filter)
        I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}")
      end
    end
  end
end
