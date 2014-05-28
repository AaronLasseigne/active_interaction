# coding: utf-8

module ActiveInteraction
  class Base
    # @!method self.complex(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Complex.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     complex :impedance
  end

  # @private
  class ComplexFilter < AbstractNumericFilter
    register :complex

    def database_column_type
      :string
    end
  end
end
