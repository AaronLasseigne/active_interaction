module ActiveInteraction
  module Validation
    def self.validate(filters, inputs)
      filters.reduce([]) do |errors, filter|
        begin
          Caster.cast(filter, inputs[filter.name])

          errors
        rescue InvalidNestedValue
          errors << [filter.name, :invalid_nested]
        rescue InvalidValue
          errors << [filter.name, :invalid, nil, type: I18n.translate("#{Base.i18n_scope}.types.#{filter.type.to_s}")]
        rescue MissingValue
          errors << [filter.name, :missing]
        end
      end
    end
  end
end
