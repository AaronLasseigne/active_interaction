# coding: utf-8
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
    #
    #   @since 1.2.0
  end

  # @private
  class DecimalFilter < AbstractNumericFilter
    register :decimal

    private

    # @return [Integer]
    def digits
      options.fetch(:digits, 0)
    end

    def klass
      BigDecimal
    end

    def converter(value)
      Float(value) if value.is_a?(String)
      Kernel.public_send(klass.name, value, digits)
    end
  end
end
