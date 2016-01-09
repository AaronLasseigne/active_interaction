# coding: utf-8
# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.integer(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Integers. String values are converted into
    #     Integers.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     integer :quantity
  end

  # @private
  class IntegerFilter < AbstractNumericFilter
    register :integer
  end
end
