module ActiveInteraction
  class SymbolFilter < Filter
    # @param value [Object]
    #
    # @return [Symbol]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when Symbol
        value
      when String
        value.to_sym
      else
        super
      end
    end
  end
end
