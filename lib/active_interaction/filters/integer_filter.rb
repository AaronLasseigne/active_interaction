# frozen_string_literal: true

module ActiveInteraction
  class Base
    # @!method self.integer(*attributes, options = {})
    #   Creates accessors for the attributes and ensures that values passed to
    #     the attributes are Integers. String values are converted into
    #     Integers.
    #
    #   @!macro filter_method_params
    #   @option options [Integer] :base (10) The base used to convert strings
    #     into integers. When set to `0` it will honor radix indicators (i.e.
    #     0, 0b, and 0x).
    #
    #   @example
    #     integer :quantity
  end

  # @private
  class IntegerFilter < AbstractNumericFilter
    register :integer

    private

    # @return [Integer]
    def base
      options.fetch(:base, 10)
    end

    def convert(value, context)
      Integer(value, value.is_a?(String) ? base : 0)
    rescue ArgumentError
      _cast(value, context)
    end
  end
end
