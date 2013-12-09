# coding: utf-8

module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Floats. Integer and String values are converted into
    #   Floats.
    #
    # @macro filter_method_params
    #
    # @example
    #   float :amount
    #
    # @since 0.1.0
    #
    # @method self.float(*attributes, options = {})
  end

  # @private
  class FloatFilter < AbstractNumericFilter
    private

    def klass
      Float
    end
  end
end
