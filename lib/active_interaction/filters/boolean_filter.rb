module ActiveInteraction
  class Base
    # Confirms that any values passed to the provided attributes are Booleans.
    #   The String "1" is converted to `true` and "0" is converted to `false`.
    #
    # @macro attribute_method_params
    #
    # @example
    #   boolean :subscribed
    #
    # @method self.boolean(*attributes, options = {})
  end

  # @private
  class BooleanFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      case value
        when TrueClass, FalseClass
          value
        when '0'
          false
        when '1'
          true
        else
          super
      end
    end
  end
end
