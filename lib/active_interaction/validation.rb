module ActiveInteraction
  module Validation
    def self.validate(filters, inputs)
      filters.reduce([]) do |errors, filter|
        begin
          filter.cast(inputs[filter.name])

          errors
        rescue InvalidValue
          errors << [filter.name, :invalid, nil, type: I18n.translate("#{Base.i18n_scope}.types.#{filter.class.slug}")]
        rescue MissingValue
          errors << [filter.name, :missing]
        end
      end
    end
  end
end
