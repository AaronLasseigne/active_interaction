# coding: utf-8

module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Integers. String values are converted into Integers.
    #
    # @macro filter_method_params
    #
    # @example
    #   integer :quantity
    #
    # @since 0.1.0
    #
    # @method self.integer(*attributes, options = {})
  end

  # @private
  class IntegerFilter < AbstractNumericFilter
  end
end
