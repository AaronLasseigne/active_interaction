# coding: utf-8

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
    #
    #   @since 1.2.0
  end

  # @private
  class DecimalFilter < AbstractNumericFilter
    def cast(value)
      case value
      when Numeric
        BigDecimal.new(value, digits)
      when String
        decimal_from_string(value)
      else
        super
      end
    end

    private

    # @return [Integer]
    def digits
      options.fetch(:digits, 0)
    end

    # @param value [String] string that has to be converted
    #
    # @return [BigDecimal]
    #
    # @raise [InvalidValueError] if given value can not be converted
    def decimal_from_string(value)
      Float(value)
      BigDecimal.new(value, digits)
    rescue ArgumentError
       raise InvalidValueError, "Given value: #{value.inspect}"
    end

    def klass
      BigDecimal
    end
  end
end
