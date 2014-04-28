module ActiveInteraction
  class Base
    # @!method self.decimal(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are BigDecimals. Numerics and String values are
    #     converted into BigDecimals.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     decimal :amount
  end

  # @private
  class DecimalFilter < Filter
    def cast(value)
      case value
      when Float
        BigDecimal.new(value.to_s)
      when String, Numeric
        Float(value) rescue fail(InvalidValueError, "Given value: #{value.inspect}")
        BigDecimal.new(value)
      else
        super
      end
    end
  end
end
