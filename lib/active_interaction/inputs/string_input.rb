module ActiveInteraction
  class StringInput < Input
    # @param value [Object]
    #
    # @return [String]
    #
    # @raise (see Input#cast)
    def cast(value)
      case value
      when String
        if @options.fetch(:strip, true)
          value.strip
        else
          value
        end
      else
        super
      end
    end
  end
end
