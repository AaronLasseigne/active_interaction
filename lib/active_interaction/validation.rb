module ActiveInteraction
  module Validation
    def self.validate(filters, inputs)
      filters.reduce([]) do |errors, input|
        begin
          input.cast(inputs[input.name])

          errors
        rescue InvalidValue
          errors << [input.name, :invalid, nil, type: I18n.translate("#{Base.i18n_scope}.types.#{input.class.slug}")]
        rescue MissingValue
          errors << [input.name, :missing]
        end
      end
    end
  end
end
