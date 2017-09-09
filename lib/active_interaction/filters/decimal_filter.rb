# frozen_string_literal: true

require 'bigdecimal'

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
    register :decimal

    def cast(value, _interaction)
      case value
      when Numeric
        BigDecimal(value, digits)
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
      BigDecimal(value, digits)
    rescue ArgumentError
      raise InvalidValueError, "Given value: #{value.inspect}"
    end

    def klass
      BigDecimal
    end
  end
end
