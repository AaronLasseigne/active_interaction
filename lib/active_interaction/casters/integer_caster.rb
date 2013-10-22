module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Integers. String values are converted into Integers.
    #
    # @macro attribute_method_params
    #
    # @example
    #   integer :quantity
    #
    # @method self.integer(*attributes, options = {})
  end

  # @private
  class IntegerCaster < Caster
    def self.prepare(filter, value)
      case value
        when Integer
          value
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
