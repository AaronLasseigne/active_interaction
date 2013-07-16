module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Floats. Integer and String values are converted into
    #   Floats.
    #
    # @macro attribute_method_params
    #
    # @example
    #   float :amount
    #
    # @method self.float(*attributes, options = {})
  end

  # @private
  class FloatFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      case value
        when Float
          value
        when Integer, String
          begin
            Float(value)
          rescue ArgumentError
            super
          end
        else
          super
      end
    end
  end
end
