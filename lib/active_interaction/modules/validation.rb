# coding: utf-8

module ActiveInteraction
  # Validates inputs using filters.
  #
  # @private
  module Validation
    # @param filters [Hash{Symbol => Filter}]
    # @param inputs [Hash{Symbol => Object}]
    def self.validate(filters, inputs)
      filters.each_with_object([]) do |(name, filter), errors|
        begin
          filter.cast(inputs[name])
        rescue InvalidNestedValueError,
               InvalidValueError,
               MissingValueError => e
          errors << error_args(filter, e)
        end
      end
    end

    private

    def self.error_args(filter, error)
      case error
      when InvalidNestedValueError
        [filter.name, :invalid_nested, nil,
         name: e.name.inspect, value: e.value.inspect]
      when InvalidValueError
        [filter.name, :invalid_type, nil, type: type(filter)]
      when MissingValueError
        [filter.name, :missing]
      end
    end

    # @param filter [Filter]
    def self.type(filter)
      I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}")
    end
  end
end
