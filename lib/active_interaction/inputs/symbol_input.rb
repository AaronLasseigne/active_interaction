module ActiveInteraction
  class SymbolInput < Input
    # @param value [Object]
    #
    # @return [Symbol]
    #
    # @raise (see Input#cast)
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
