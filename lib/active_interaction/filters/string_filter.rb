module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Strings.
    #
    # @macro attribute_method_params
    #
    # @example
    #   string :first_name
    #
    # @method self.string(*attributes, options = {})
  end

  # @private
  class StringFilter < Filter
    def self.prepare(key, value, options = {}, &block)
      case value
        when String
          value
        else
          super
      end
    end
  end
end
