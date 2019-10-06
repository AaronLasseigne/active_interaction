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

    private

    def digits
      options.fetch(:digits, 0)
    end

    def klass
      BigDecimal
    end

    def converter(value)
      # Ruby < 2.4 does not throw an error in BigDecimal
      # for invalid strings. We'll simulate the error by
      # calling Float.
      Float(value) if value.is_a?(String)

      BigDecimal(value, digits)
    end
  end
end
