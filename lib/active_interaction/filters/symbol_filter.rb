module ActiveInteraction
  # @private
  class SymbolFilter < Filter
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
