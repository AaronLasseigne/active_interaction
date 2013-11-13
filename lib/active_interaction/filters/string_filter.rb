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
        strip? ? value.strip : value
      else
        super
      end
    end

    private

    def strip?
      options.fetch(:strip, true)
    end
  end
end
