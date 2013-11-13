module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Strings.
    #
    # @macro attribute_method_params
    # @option options [Boolean] :strip (true) strip leading and trailing
    #   whitespace
    #
    # @example
    #   string :first_name
    #
    # @example
    #   string :first_name, strip: false
    #
    # @method self.string(*attributes, options = {})
  end

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
