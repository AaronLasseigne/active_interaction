module ActiveInteraction
  class Base
    # Creates accessors for the attributes and ensures that values passed to
    #   the attributes are Strings.
    #
    # @macro attribute_method_params
    # @option options [Boolean] :strip (true) Strip leading and trailing
    #   whitespace.
    #
    # @example
    #   string :first_name
    #
    # @method self.string(*attributes, options = {})
  end

  # @private
  class StringCaster < Caster
    def self.prepare(key, value, options = {}, &block)
      case value
        when String
          options.fetch(:strip, true) ? value.strip : value
        else
          super
      end
    end
  end
end
