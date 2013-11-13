module ActiveInteraction
  class IntegerInput < Input
    # @param value [Object]
    #
    # @return [Integer]
    #
    # @raise (see Input#cast)
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
