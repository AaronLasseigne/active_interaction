module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Booleans. The String `"1"` is converted to `true`
    #   and `"0"` is converted to `false`.
    #
    # @macro filter_method_params
    #
    # @example
    #   boolean :subscribed
    #
    # @since 0.1.0
    #
    # @method self.boolean(*attributes, options = {})
  end

  # @private
  class BooleanFilter < Filter
    def cast(value)
      case value
      when FalseClass, '0'
        false
      when TrueClass, '1'
        true
      else
        super
      end
    end
  end
end
