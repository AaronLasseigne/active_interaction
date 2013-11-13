module ActiveInteraction
  # @private
  class StringFilter < Filter
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
