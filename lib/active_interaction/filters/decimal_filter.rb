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
    #     decimal :amount, digits: 4
  end

  # @private
  class DecimalFilter < AbstractNumericFilter
    def initialize(*)
      @klass = BigDecimal

      super
    end

    def cast(value)
      case value
      when Numeric
        BigDecimal.new(value, digits)
      when String
        begin
          decimal_like_value = Float(value)
          BigDecimal.new(value, digits)
        rescue ArgumentError
         raise InvalidValueError, "Given value: #{value.inspect}"
        end
      else
        super
      end
    end

    private

    # @return [Integer]
    def digits
      options.fetch(:digits, 0)
    end
  end
end
