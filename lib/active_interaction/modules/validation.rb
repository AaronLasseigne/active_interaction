# coding: utf-8

module ActiveInteraction
  # @private
  module Validation
    def self.validate(filters, inputs)
      filters.each_with_object([]) do |(name, filter), errors|
        begin
          filter.cast(inputs[name])
        rescue InvalidValueError
          errors << [name, :invalid, nil, type: type(filter)]
        rescue MissingValueError
          errors << [name, :missing]
        end
      end
    end

    private

    def self.type(filter)
      I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}")
    end
  end
end
