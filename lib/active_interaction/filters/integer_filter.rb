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
  class IntegerFilter < Filter
    def cast(value)
      case value
      when Numeric
        value.to_i
      when String
        begin
          Integer(value)
        rescue ArgumentError
          super
        end
      else
        super
      end
    end
  end
end
