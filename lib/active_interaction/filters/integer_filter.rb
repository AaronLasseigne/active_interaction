module ActiveInteraction
  class Base
    # Confirms that any values passed to the provided attributes are Integers.
    #   String values are converted into Integers.
    #
    # @macro attribute_method_params
    #
    # @example
    #   integer :quantity
    #
    # @method self.integer(*attributes, options = {})
  end

  # @private
  class IntegerFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      case value
        when Integer
          value
        when String
          begin
            Integer(value)
          rescue ArgumentError
            bad_value
          end
        else
          super
      end
    end
  end
end
