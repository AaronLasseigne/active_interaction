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
          filter.clean(inputs[name], context)
        rescue NoDefaultError
          nil
        rescue InvalidNestedValueError => e
          errors << [filter.name, :invalid_nested, { name: e.filter_name.inspect, value: e.input_value.inspect }]
        rescue InvalidValueError
          errors << [filter.name, :invalid_type, { type: type(filter) }]
        rescue MissingValueError
          errors << [filter.name, :missing]
        end
      end

      private

      # @param filter [Filter]
      def type(filter)
        I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}")
      end
    end
  end
end
