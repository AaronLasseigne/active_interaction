# coding: utf-8

module ActiveInteraction
  # @private
  module Validation
    def self.validate(filters, inputs)
      filters.each_with_object([]) do |filter, errors|
        begin
          filter.cast(inputs[filter.name])
        rescue InvalidValueError
          errors << [filter.name, :invalid, nil, type: type(filter)]
        rescue MissingValueError
          errors << [filter.name, :missing]
        end
      end
    end

    private

    def self.type(filter)
      I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}")
    end
  end
end
