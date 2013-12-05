module ActiveInteraction
  # @private
  module Validation
    def self.validate(filters, inputs)
      filters.each_with_object([]) do |filter, errors|
        begin
          filter.cast(inputs[filter.name])
        rescue InvalidValueError
          type = I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}")
          errors << [filter.name, :invalid, nil, type: type]
        rescue MissingValueError
          errors << [filter.name, :missing]
        end
      end
    end
  end
end
