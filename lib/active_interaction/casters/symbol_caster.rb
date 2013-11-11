module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Symbols. Strings will be converted to Symbols.
    #
    # @macro attribute_method_params
    #
    # @example
    #   symbol :condiment
    #
    # @method self.symbol(*attributes, options = {})
  end

  # @private
  class SymbolCaster < Caster
    def self.prepare(filter, value)
      case value
        when String
          value.to_sym
        when Symbol
          value
        else
          super
      end
    end
  end
end
