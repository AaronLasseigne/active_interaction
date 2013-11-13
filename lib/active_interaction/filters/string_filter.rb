module ActiveInteraction
  class StringFilter < Filter
    # @param value [Object]
    #
    # @return [String]
    #
    # @raise (see Filter#cast)
    def cast(value)
      case value
      when String
        if options.fetch(:strip, true)
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
