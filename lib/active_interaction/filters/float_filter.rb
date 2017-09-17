# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.float(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Floats. Integer and String values are converted
    #     into Floats.
    #
    #   @!macro filter_method_params
    #
    #   @example
    #     float :amount
  end

  # @private
  class FloatFilter < AbstractNumericFilter
    register :float
  end
end
