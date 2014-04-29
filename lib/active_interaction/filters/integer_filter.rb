# coding: utf-8

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
    def database_column_type
      :integer
    end
  end
end
