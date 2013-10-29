module ActiveInteraction
  module Validation
    def self.run(filters, inputs)
      errors = []

      filters.each do |filter|
        begin
          Caster.cast(filter, inputs[filter.name])
        rescue InvalidNestedValue
          errors << [filter.name, :invalid_nested]
        rescue InvalidValue
          errors << [filter.name, :invalid, nil, type: I18n.translate("#{Base.i18n_scope}.types.#{filter.type.to_s}")]
        rescue MissingValue
          errors << [filter.name, :missing]
        end
      end

      errors
    end
  end
end
