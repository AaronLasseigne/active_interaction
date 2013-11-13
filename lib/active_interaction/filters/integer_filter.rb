module ActiveInteraction
  class IntegerFilter < Filter
    # @param value [Object]
    #
    # @return [Integer]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when Numeric
        value.to_i
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
