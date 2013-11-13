module ActiveInteraction
  class BooleanFilter < Filter
    # @param value [Object]
    #
    # @return [Boolean]
    #
    # @raise (see Filter#cast)
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
