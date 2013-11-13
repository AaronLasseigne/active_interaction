module ActiveInteraction
  class BooleanInput < Input
    # @param value [Object]
    #
    # @return [Boolean]
    #
    # @raise (see Input#cast)
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
