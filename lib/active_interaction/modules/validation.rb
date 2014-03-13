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
        rescue InvalidValueError
          errors << [name, :invalid_type, nil, type: type(filter)]
        rescue MissingValueError
          errors << [name, :missing]
        rescue InvalidNestedValueError => e
          errors << [name, :invalid_nested, nil,
                     name: e.name.inspect, value: e.value.inspect]
        end
      end
    end

    private

    # @param filter [Filter]
    def self.type(filter)
      I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}")
    end
  end
end
